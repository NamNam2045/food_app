package com.foodrush.shipper.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.order.entity.Order;
import com.foodrush.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ShipperService {

    private final OrderRepository orderRepository;

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
                .filter(o -> o.getDeliveryAgent() != null
                        && o.getDeliveryAgent().getId().equals(agentId));
    }

    public void acceptOrder(Long orderId, Long agentId) {
        Order order = orderRepository.findById(orderId)
                .filter(o -> o.getStatus() == OrderStatus.READY_FOR_PICKUP
                        && o.getDeliveryAgent() == null)
                .orElseThrow(() -> new RuntimeException("Order không khả dụng để nhận"));
        // assign & update status
        com.foodrush.user.entity.User agent = new com.foodrush.user.entity.User();
        agent.setId(agentId);
        order.setDeliveryAgent(agent);
        order.setStatus(OrderStatus.PICKED_UP);
        orderRepository.save(order);
    }

    public void updateStatus(Long orderId, Long agentId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .filter(o -> o.getDeliveryAgent() != null
                        && o.getDeliveryAgent().getId().equals(agentId))
                .orElseThrow(() -> new RuntimeException("Order not found or not assigned to you"));
        if (newStatus == OrderStatus.DELIVERED) {
            order.setDeliveredAt(java.time.LocalDateTime.now());
        }
        order.setStatus(newStatus);
        orderRepository.save(order);
    }
}
