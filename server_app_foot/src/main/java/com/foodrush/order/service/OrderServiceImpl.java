package com.foodrush.order.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.foodrush.cart.entity.Cart;
import com.foodrush.cart.service.CartService;
import com.foodrush.common.dto.PageResponse;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.enums.PaymentMethod;
import com.foodrush.common.enums.PaymentStatus;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.notification.service.NotificationService;
import com.foodrush.order.dto.*;
import com.foodrush.order.entity.Order;
import com.foodrush.order.entity.OrderItem;
import com.foodrush.order.entity.OrderStatusHistory;
import com.foodrush.order.entity.PromoCode;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.order.repository.PromoCodeRepository;
import com.foodrush.payment.entity.Payment;
import com.foodrush.payment.repository.PaymentRepository;
import com.foodrush.user.entity.Address;
import com.foodrush.user.repository.AddressRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final AddressRepository addressRepository;
    private final CartService cartService;
    private final PaymentRepository paymentRepository;
    private final PromoCodeRepository promoCodeRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final ObjectMapper objectMapper;
    private final NotificationService notificationService;

    @Override
    public OrderResponse placeOrder(PlaceOrderRequest request, Long userId) {
        Cart cart = cartService.getCartByUserId(userId);

        if (cart.getItems().isEmpty()) {
            throw new BusinessRuleException("CART_001", "Giỏ hàng trống");
        }

        Address address = addressRepository.findById(request.getDeliveryAddressId())
                .filter(a -> a.getUser().getId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Địa chỉ giao hàng không tồn tại"));

        BigDecimal subtotal = cart.getItems().stream()
                .map(ci -> ci.getUnitPrice().multiply(BigDecimal.valueOf(ci.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal deliveryFee = cart.getRestaurant().getDeliveryFee();

        if (subtotal.compareTo(cart.getRestaurant().getMinOrderAmount()) < 0) {
            throw new BusinessRuleException("ORDER_002",
                    "Đơn hàng tối thiểu " + cart.getRestaurant().getMinOrderAmount() + "đ");
        }

        // Validate promo code
        PromoValidationResult promoResult = validatePromoCode(request.getPromoCode(), subtotal);
        BigDecimal discountAmount = promoResult.getDiscountAmount();

        String addressSnapshot = buildAddressSnapshot(address);

        Order order = Order.builder()
                .orderNumber(generateOrderNumber())
                .user(cart.getUser())
                .restaurant(cart.getRestaurant())
                .status(OrderStatus.PENDING)
                .deliveryAddressSnapshot(addressSnapshot)
                .subtotal(subtotal)
                .deliveryFee(deliveryFee)
                .discountAmount(discountAmount)
                .totalAmount(subtotal.add(deliveryFee).subtract(discountAmount))
                .specialInstructions(request.getSpecialInstructions())
                .estimatedDeliveryAt(LocalDateTime.now().plusMinutes(cart.getRestaurant().getEstimatedDeliveryMinutes()))
                .build();

        // Tạo order items
        List<OrderItem> items = cart.getItems().stream().map(ci -> OrderItem.builder()
                .order(order).menuItem(ci.getMenuItem())
                .menuItemName(ci.getMenuItem().getName()).quantity(ci.getQuantity())
                .unitPrice(ci.getUnitPrice())
                .subtotal(ci.getUnitPrice().multiply(BigDecimal.valueOf(ci.getQuantity())))
                .specialInstructions(ci.getSpecialInstructions())
                .build()).collect(Collectors.toList());
        order.setItems(items);

        // Ghi lịch sử status ban đầu
        order.getStatusHistory().add(OrderStatusHistory.builder()
                .order(order).status(OrderStatus.PENDING)
                .notes("Đơn hàng được tạo").changedByUserId(userId).build());

        Order saved = orderRepository.save(order);

        // Tạo payment record
        Payment payment = Payment.builder()
                .order(saved).paymentMethod(request.getPaymentMethod())
                .paymentStatus(PaymentStatus.PENDING).amount(saved.getTotalAmount()).build();
        paymentRepository.save(payment);

        // Tăng usedCount promo code nếu có
        if (promoResult.isValid() && request.getPromoCode() != null) {
            promoCodeRepository.findByCodeAndActiveTrue(request.getPromoCode().toUpperCase())
                    .ifPresent(pc -> promoCodeRepository.incrementUsedCount(pc.getId()));
        }

        // Xóa giỏ hàng
        cartService.clearCart(userId);

        // Notify via WebSocket
        notifyStatusUpdate(saved, null);

        return toOrderResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> getMyOrders(Long userId, OrderStatus status, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Order> orders = (status != null)
                ? orderRepository.findByUserIdAndStatus(userId, status, pageable)
                : orderRepository.findByUserId(userId, pageable);
        return PageResponse.from(orders.map(this::toOrderSummary));
    }

    @Override
    @Transactional(readOnly = true)
    public OrderResponse getOrderById(Long orderId, Long userId) {
        Order order = findOrder(orderId);
        if (!order.getUser().getId().equals(userId)) {
            throw new BusinessRuleException("FORBIDDEN", "Bạn không có quyền xem đơn hàng này");
        }
        return toOrderResponse(order);
    }

    @Override
    public OrderResponse cancelOrder(Long orderId, CancelOrderRequest request, Long userId) {
        Order order = findOrder(orderId);
        if (!order.getUser().getId().equals(userId)) {
            throw new BusinessRuleException("FORBIDDEN", "Bạn không có quyền hủy đơn hàng này");
        }
        if (!EnumSet.of(OrderStatus.PENDING, OrderStatus.CONFIRMED).contains(order.getStatus())) {
            throw new BusinessRuleException("ORDER_001", "Không thể hủy đơn hàng ở trạng thái " + order.getStatus());
        }

        OrderStatus prev = order.getStatus();
        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());
        order.setCancellationReason(request.getReason());
        order.getStatusHistory().add(OrderStatusHistory.builder()
                .order(order).status(OrderStatus.CANCELLED)
                .notes(request.getReason()).changedByUserId(userId).build());

        Order saved = orderRepository.save(order);
        notifyStatusUpdate(saved, prev);
        return toOrderResponse(saved);
    }

    @Override
    public OrderResponse updateStatus(Long orderId, UpdateOrderStatusRequest request, Long actorId) {
        Order order = findOrder(orderId);
        validateStatusTransition(order.getStatus(), request.getStatus());

        OrderStatus prev = order.getStatus();
        order.setStatus(request.getStatus());

        if (request.getStatus() == OrderStatus.DELIVERED) {
            order.setDeliveredAt(LocalDateTime.now());
        }

        order.getStatusHistory().add(OrderStatusHistory.builder()
                .order(order).status(request.getStatus())
                .notes(request.getNotes()).changedByUserId(actorId).build());

        Order saved = orderRepository.save(order);
        notifyStatusUpdate(saved, prev);
        return toOrderResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> getRestaurantOrders(Long restaurantId, OrderStatus status,
            String date, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        if (date != null && !date.isBlank()) {
            LocalDate localDate = LocalDate.parse(date); // format: yyyy-MM-dd
            startDate = localDate.atStartOfDay();
            endDate = localDate.plusDays(1).atStartOfDay();
        }

        Page<Order> orders = orderRepository.findByRestaurantWithFilters(
                restaurantId, status, startDate, endDate, pageable);
        return PageResponse.from(orders.map(this::toOrderSummary));
    }

    private Order findOrder(Long orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));
    }

    private void validateStatusTransition(OrderStatus current, OrderStatus next) {
        Map<OrderStatus, EnumSet<OrderStatus>> allowed = Map.of(
                OrderStatus.PENDING, EnumSet.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED),
                OrderStatus.CONFIRMED, EnumSet.of(OrderStatus.PREPARING, OrderStatus.CANCELLED),
                OrderStatus.PREPARING, EnumSet.of(OrderStatus.READY_FOR_PICKUP),
                OrderStatus.READY_FOR_PICKUP, EnumSet.of(OrderStatus.PICKED_UP),
                OrderStatus.PICKED_UP, EnumSet.of(OrderStatus.ON_THE_WAY),
                OrderStatus.ON_THE_WAY, EnumSet.of(OrderStatus.DELIVERED)
        );
        if (!allowed.getOrDefault(current, EnumSet.noneOf(OrderStatus.class)).contains(next)) {
            throw new BusinessRuleException("ORDER_003",
                    "Không thể chuyển từ trạng thái " + current + " sang " + next);
        }
    }

    private void notifyStatusUpdate(Order order, OrderStatus prevStatus) {
        OrderStatusUpdateMessage msg = OrderStatusUpdateMessage.builder()
                .orderId(order.getId()).orderNumber(order.getOrderNumber())
                .newStatus(order.getStatus()).previousStatus(prevStatus)
                .message(getStatusMessage(order.getStatus()))
                .estimatedDeliveryAt(order.getEstimatedDeliveryAt())
                .timestamp(LocalDateTime.now()).build();

        messagingTemplate.convertAndSendToUser(
                order.getUser().getId().toString(),
                "/queue/orders/" + order.getId() + "/status",
                msg
        );

        // FCM push notification (async) using plain values to avoid lazy-loading
        // managed entities across threads.
        notificationService.sendOrderStatusUpdate(
                order.getId(),
                order.getOrderNumber(),
                order.getStatus(),
                order.getUser().getFcmToken()
        );
    }

    private String getStatusMessage(OrderStatus status) {
        return switch (status) {
            case PENDING -> "Đơn hàng đang chờ xác nhận";
            case CONFIRMED -> "Nhà hàng đã xác nhận đơn hàng";
            case PREPARING -> "Nhà hàng đang chuẩn bị đơn hàng";
            case READY_FOR_PICKUP -> "Đơn hàng đã sẵn sàng, đang chờ shipper";
            case PICKED_UP -> "Shipper đã lấy hàng";
            case ON_THE_WAY -> "Shipper đang trên đường giao hàng";
            case DELIVERED -> "Đơn hàng đã được giao thành công";
            case CANCELLED -> "Đơn hàng đã bị hủy";
        };
    }

    private PromoValidationResult validatePromoCode(String code, BigDecimal subtotal) {
        if (code == null || code.isBlank()) {
            return PromoValidationResult.invalid("Không có mã giảm giá");
        }

        PromoCode promo = promoCodeRepository.findByCodeAndActiveTrue(code.toUpperCase())
                .orElse(null);

        if (promo == null) {
            return PromoValidationResult.invalid("Mã giảm giá không tồn tại hoặc đã hết hạn");
        }

        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(promo.getStartDate()) || now.isAfter(promo.getEndDate())) {
            return PromoValidationResult.invalid("Mã giảm giá đã hết thời hạn");
        }

        if (promo.getUsedCount() >= promo.getUsageLimit()) {
            return PromoValidationResult.invalid("Mã giảm giá đã hết lượt sử dụng");
        }

        if (promo.getMinOrderAmount() != null && subtotal.compareTo(promo.getMinOrderAmount()) < 0) {
            return PromoValidationResult.invalid(
                    "Đơn hàng tối thiểu " + promo.getMinOrderAmount() + "đ để dùng mã này");
        }

        BigDecimal discount;
        if ("PERCENTAGE".equals(promo.getDiscountType())) {
            discount = subtotal.multiply(promo.getDiscountValue()).divide(BigDecimal.valueOf(100));
            if (promo.getMaxDiscountAmount() != null && discount.compareTo(promo.getMaxDiscountAmount()) > 0) {
                discount = promo.getMaxDiscountAmount();
            }
        } else {
            discount = promo.getDiscountValue();
        }

        return PromoValidationResult.valid(discount);
    }

    private String generateOrderNumber() {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        long count = orderRepository.countByCreatedAtDate(LocalDate.now()) + 1;
        return "FR-" + date + "-" + String.format("%05d", count);
    }

    private String buildAddressSnapshot(Address address) {
        try {
            return objectMapper.writeValueAsString(Map.of(
                    "label", address.getLabel(),
                    "streetLine1", address.getStreetLine1(),
                    "streetLine2", address.getStreetLine2() != null ? address.getStreetLine2() : "",
                    "city", address.getCity(),
                    "state", address.getState(),
                    "postalCode", address.getPostalCode()
            ));
        } catch (Exception e) {
            return "{}";
        }
    }

    private OrderResponse toOrderResponse(Order o) {
        List<OrderItemResponse> items = o.getItems().stream().map(i -> OrderItemResponse.builder()
                .id(i.getId()).menuItemId(i.getMenuItem().getId())
                .menuItemName(i.getMenuItemName()).quantity(i.getQuantity())
                .unitPrice(i.getUnitPrice()).subtotal(i.getSubtotal())
                .specialInstructions(i.getSpecialInstructions()).build())
                .collect(Collectors.toList());

        List<OrderStatusHistoryResponse> history = o.getStatusHistory().stream()
                .map(h -> OrderStatusHistoryResponse.builder()
                        .status(h.getStatus()).notes(h.getNotes()).createdAt(h.getCreatedAt()).build())
                .collect(Collectors.toList());

        PaymentMethod payMethod = o.getPayment() != null ? o.getPayment().getPaymentMethod() : null;
        PaymentStatus payStatus = o.getPayment() != null ? o.getPayment().getPaymentStatus() : null;

        return OrderResponse.builder()
                .id(o.getId()).orderNumber(o.getOrderNumber()).status(o.getStatus())
                .restaurantId(o.getRestaurant().getId()).restaurantName(o.getRestaurant().getName())
                .restaurantPhone(o.getRestaurant().getPhone())
                .deliveryAddressSnapshot(o.getDeliveryAddressSnapshot())
                .items(items).statusHistory(history)
                .subtotal(o.getSubtotal()).deliveryFee(o.getDeliveryFee())
                .discountAmount(o.getDiscountAmount()).totalAmount(o.getTotalAmount())
                .paymentMethod(payMethod).paymentStatus(payStatus)
                .specialInstructions(o.getSpecialInstructions())
                .estimatedDeliveryAt(o.getEstimatedDeliveryAt())
                .deliveredAt(o.getDeliveredAt()).cancelledAt(o.getCancelledAt())
                .cancellationReason(o.getCancellationReason()).createdAt(o.getCreatedAt())
                .build();
    }

    private OrderSummaryResponse toOrderSummary(Order o) {
        return OrderSummaryResponse.builder()
                .id(o.getId()).orderNumber(o.getOrderNumber()).status(o.getStatus())
                .restaurantName(o.getRestaurant().getName())
                .restaurantLogoUrl(o.getRestaurant().getLogoUrl())
                .itemCount(o.getItems().size()).totalAmount(o.getTotalAmount())
                .createdAt(o.getCreatedAt()).build();
    }
}
