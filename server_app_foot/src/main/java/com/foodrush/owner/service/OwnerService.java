package com.foodrush.owner.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.menu.entity.MenuCategory;
import com.foodrush.menu.entity.MenuItem;
import com.foodrush.menu.repository.MenuCategoryRepository;
import com.foodrush.menu.repository.MenuItemRepository;
import com.foodrush.order.entity.Order;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.restaurant.entity.Restaurant;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import com.foodrush.restaurant.repository.RestaurantRepository;
import com.foodrush.review.entity.Review;
import com.foodrush.review.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class OwnerService {

    private final RestaurantRepository restaurantRepository;
    private final OrderRepository orderRepository;
    private final MenuCategoryRepository menuCategoryRepository;
    private final MenuItemRepository menuItemRepository;
    private final ReviewRepository reviewRepository;

    // ---- Restaurant ----

    public Optional<Restaurant> getRestaurantByOwner(Long ownerId) {
        PageRequest pageable = PageRequest.of(0, 1);
        Page<Restaurant> page = restaurantRepository.findByOwnerIdAndActiveTrue(ownerId, pageable);
        return page.isEmpty() ? Optional.empty() : Optional.of(page.getContent().get(0));
    }

    // ---- Dashboard ----

    public record DashboardStats(
            long totalOrders, long pendingOrders, long todayOrders,
            BigDecimal totalRevenue, BigDecimal todayRevenue,
            long totalReviews, double avgRating,
            List<Order> recentOrders
    ) {}

    @Transactional(readOnly = true)
    public DashboardStats getDashboardStats(Long restaurantId) {
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();

        long totalOrders = orderRepository.countByRestaurantIdAndStatus(restaurantId, null) +
                orderRepository.countByRestaurantIdAndStatus(restaurantId, OrderStatus.PENDING) +
                orderRepository.findByRestaurantId(restaurantId, PageRequest.of(0, 1)).getTotalElements();
        // simpler: just total count
        totalOrders = orderRepository.findByRestaurantId(restaurantId, PageRequest.of(0, 1)).getTotalElements();

        long pendingOrders = orderRepository.countByRestaurantIdAndStatus(restaurantId, OrderStatus.PENDING);
        long todayOrders = orderRepository.countByRestaurantIdAndCreatedAtAfter(restaurantId, startOfToday);

        BigDecimal totalRevenue = orderRepository.sumDeliveredByRestaurant(restaurantId);
        BigDecimal todayRevenue = orderRepository.sumDeliveredByRestaurantAfter(restaurantId, startOfToday);

        long totalReviews = reviewRepository.countByRestaurantId(restaurantId);
        Double avg = reviewRepository.findAverageRatingByRestaurantId(restaurantId);
        double avgRating = avg != null ? avg : 0.0;

        List<Order> recentOrders = orderRepository.findRecentByRestaurant(
                restaurantId, PageRequest.of(0, 8));

        return new DashboardStats(totalOrders, pendingOrders, todayOrders,
                totalRevenue, todayRevenue, totalReviews, avgRating, recentOrders);
    }

    // ---- Orders ----

    @Transactional(readOnly = true)
    public Page<Order> getOrders(Long restaurantId, OrderStatus status, String date, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        if (date != null && !date.isBlank()) {
            LocalDate ld = LocalDate.parse(date);
            startDate = ld.atStartOfDay();
            endDate = ld.plusDays(1).atStartOfDay();
        }
        final LocalDateTime fStart = startDate;
        final LocalDateTime fEnd = endDate;
        final OrderStatus fStatus = status;
        Specification<Order> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("restaurant").get("id"), restaurantId));
            if (fStatus != null) predicates.add(cb.equal(root.get("status"), fStatus));
            if (fStart != null) predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), fStart));
            if (fEnd != null) predicates.add(cb.lessThan(root.get("createdAt"), fEnd));
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        return orderRepository.findAll(spec, pageable);
    }

    @Transactional(readOnly = true)
    public Optional<Order> getOrderById(Long orderId, Long restaurantId) {
        return orderRepository.findByIdWithDetails(orderId)
                .filter(o -> o.getRestaurant().getId().equals(restaurantId));
    }

    public void updateOrderStatus(Long orderId, Long restaurantId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .filter(o -> o.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new RuntimeException("Order not found or not yours"));
        order.setStatus(newStatus);
        orderRepository.save(order);
    }

    // ---- Menu ----

    @Transactional(readOnly = true)
    public List<MenuCategory> getCategories(Long restaurantId) {
        return menuCategoryRepository.findByRestaurantIdAndActiveTrueOrderByDisplayOrderAsc(restaurantId);
    }

    @Transactional(readOnly = true)
    public List<MenuItem> getItemsByCategory(Long categoryId) {
        return menuItemRepository.findByCategoryIdOrderByDisplayOrderAsc(categoryId);
    }

    @Transactional(readOnly = true)
    public Optional<MenuItem> getMenuItemById(Long itemId, Long restaurantId) {
        return menuItemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId));
    }

    public void toggleItemAvailable(Long itemId, Long restaurantId) {
        menuItemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .ifPresent(item -> {
                    item.setAvailable(!item.isAvailable());
                    menuItemRepository.save(item);
                });
    }

    // ---- Reviews ----

    @Transactional(readOnly = true)
    public Page<Review> getReviews(Long restaurantId, int page, int size) {
        return reviewRepository.findByRestaurantForOwner(restaurantId,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }
}
