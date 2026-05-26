package com.foodrush.shipper.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.order.entity.Order;
import com.foodrush.order.entity.OrderStatusHistory;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.order.service.OrderStatusTransitions;
import com.foodrush.user.entity.User;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ShipperService {

    private final OrderRepository orderRepository;
    private final EntityManager entityManager;

    // --- Dashboard ---

    public record DashboardStats(
            long totalDelivered, long activeDeliveries, List<Order> activeOrders, List<Order> availableOrders
    ) {}

    @Transactional(readOnly = true)
    public DashboardStats getDashboardStats(Long agentId) {
        long totalDelivered = orderRepository.countByDeliveryAgentIdAndStatus(agentId, OrderStatus.DELIVERED);
        List<Order> activeOrders = orderRepository.findActiveForShipper(agentId);
        List<Order> availableOrders = orderRepository.findAvailableForPickup();
        return new DashboardStats(totalDelivered, activeOrders.size(), activeOrders, availableOrders);
    }

    // --- Orders ---

    @Transactional(readOnly = true)
    public Page<Order> getMyOrders(Long agentId, int page, int size) {
        return orderRepository.findByDeliveryAgentForShipper(agentId,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    @Transactional(readOnly = true)
    public Optional<Order> getOrderById(Long orderId, Long agentId) {
        return orderRepository.findByIdWithDetails(orderId)
                .filter(o -> isAssignedTo(o, agentId));
    }

    /**
     * Shipper nhận đơn từ trạng thái READY_FOR_PICKUP. Đơn chưa được gán shipper nào
     * và sau khi nhận sẽ tự động chuyển sang PICKED_UP.
     */
    public void acceptOrder(Long orderId, Long agentId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));
        if (order.getStatus() != OrderStatus.READY_FOR_PICKUP) {
            throw new BusinessRuleException("ORDER_003",
                    "Chỉ có thể nhận đơn ở trạng thái READY_FOR_PICKUP (hiện: " + order.getStatus() + ")");
        }
        if (order.getDeliveryAgent() != null) {
            throw new BusinessRuleException("ORDER_004", "Đơn này đã có shipper khác nhận");
        }

        OrderStatusTransitions.ensureShipperAllowed(order.getStatus(), OrderStatus.PICKED_UP);

        // Dùng getReference để không trigger SELECT cho User; tránh việc tạo
        // User detached/transient gây vấn đề với cascade.
        User agentRef = entityManager.getReference(User.class, agentId);
        order.setDeliveryAgent(agentRef);
        order.setStatus(OrderStatus.PICKED_UP);
        order.getStatusHistory().add(OrderStatusHistory.builder()
                .order(order)
                .status(OrderStatus.PICKED_UP)
                .notes("Shipper đã nhận đơn")
                .changedByUserId(agentId)
                .build());
        orderRepository.save(order);
    }

    /**
     * Shipper cập nhật trạng thái đơn đang giao. Chỉ chấp nhận các bước
     * PICKED_UP → ON_THE_WAY → DELIVERED và chỉ trên đơn của chính shipper.
     */
    public void updateStatus(Long orderId, Long agentId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));
        if (!isAssignedTo(order, agentId)) {
            throw new BusinessRuleException("FORBIDDEN", "Đơn này không thuộc về bạn");
        }

        OrderStatusTransitions.ensureShipperAllowed(order.getStatus(), newStatus);

        order.setStatus(newStatus);
        if (newStatus == OrderStatus.DELIVERED) {
            order.setDeliveredAt(LocalDateTime.now());
        }
        order.getStatusHistory().add(OrderStatusHistory.builder()
                .order(order)
                .status(newStatus)
                .notes("Shipper cập nhật trạng thái")
                .changedByUserId(agentId)
                .build());
        orderRepository.save(order);
    }

    private boolean isAssignedTo(Order order, Long agentId) {
        return order.getDeliveryAgent() != null
                && order.getDeliveryAgent().getId() != null
                && order.getDeliveryAgent().getId().equals(agentId);
    }
}
