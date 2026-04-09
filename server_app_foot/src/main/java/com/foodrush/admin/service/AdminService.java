package com.foodrush.admin.service;

import com.foodrush.admin.dto.DashboardStats;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.menu.entity.MenuCategory;
import com.foodrush.menu.entity.MenuItem;
import com.foodrush.menu.repository.MenuCategoryRepository;
import com.foodrush.menu.repository.MenuItemRepository;
import com.foodrush.order.entity.Order;
import com.foodrush.order.entity.PromoCode;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.order.repository.PromoCodeRepository;
import com.foodrush.payment.repository.PaymentRepository;
import com.foodrush.restaurant.entity.Restaurant;
import com.foodrush.restaurant.repository.RestaurantRepository;
import com.foodrush.review.entity.Review;
import com.foodrush.review.repository.ReviewRepository;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
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
public class AdminService {

    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final ReviewRepository reviewRepository;
    private final PromoCodeRepository promoCodeRepository;
    private final MenuCategoryRepository menuCategoryRepository;
    private final MenuItemRepository menuItemRepository;

    // ---- Dashboard ----
    @Transactional(readOnly = true)
    public DashboardStats getDashboardStats() {
        long totalUsers = userRepository.count();
        long totalRestaurants = restaurantRepository.count();
        long totalOrders = orderRepository.count();
        long totalReviews = reviewRepository.count();
        long pendingOrders = orderRepository.countByStatus(OrderStatus.PENDING);
        long activeRestaurants = restaurantRepository.countByActiveTrue();

        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        long ordersToday = orderRepository.countByCreatedAtAfter(startOfToday);

        BigDecimal totalRevenue = paymentRepository.sumPaidAmount();
        BigDecimal revenueToday = paymentRepository.sumPaidAmountAfter(startOfToday);

        return DashboardStats.builder()
                .totalUsers(totalUsers)
                .totalRestaurants(totalRestaurants)
                .totalOrders(totalOrders)
                .totalOrdersToday(ordersToday)
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .revenueToday(revenueToday != null ? revenueToday : BigDecimal.ZERO)
                .pendingOrders(pendingOrders)
                .activeRestaurants(activeRestaurants)
                .totalReviews(totalReviews)
                .build();
    }

    @Transactional(readOnly = true)
    public List<Order> getRecentOrders(int limit) {
        return orderRepository.findRecentForAdmin(
                PageRequest.of(0, limit));
    }

    // ---- Users ----
    @Transactional(readOnly = true)
    public Page<User> getUsers(String search, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        if (search != null && !search.isBlank()) {
            return userRepository.searchUsers(search.trim(), pageable);
        }
        return userRepository.findAll(pageable);
    }

    public User toggleUserActive(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setActive(!user.isActive());
        return userRepository.save(user);
    }

    // ---- Restaurants ----
    @Transactional(readOnly = true)
    public Page<Restaurant> getRestaurants(String search, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        if (search != null && !search.isBlank()) {
            return restaurantRepository.findWithFilters(null, null, search.trim(), null, pageable);
        }
        return restaurantRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Optional<Restaurant> getRestaurantById(Long id) {
        return restaurantRepository.findById(id);
    }

    public Restaurant toggleRestaurantOpen(Long restaurantId) {
        Restaurant r = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        r.setOpen(!r.isOpen());
        return restaurantRepository.save(r);
    }

    public Restaurant toggleRestaurantActive(Long restaurantId) {
        Restaurant r = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        r.setActive(!r.isActive());
        return restaurantRepository.save(r);
    }

    // ---- Orders ----
    @Transactional(readOnly = true)
    public Page<Order> getOrders(OrderStatus status, String date, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        if (date != null && !date.isBlank()) {
            LocalDate localDate = LocalDate.parse(date);
            startDate = localDate.atStartOfDay();
            endDate = localDate.plusDays(1).atStartOfDay();
        }
        Specification<Order> spec = buildOrderSpec(status, startDate, endDate);
        return orderRepository.findAll(spec, pageable);
    }

    private Specification<Order> buildOrderSpec(OrderStatus status, LocalDateTime startDate, LocalDateTime endDate) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), startDate));
            }
            if (endDate != null) {
                predicates.add(cb.lessThan(root.get("createdAt"), endDate));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    @Transactional(readOnly = true)
    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }

    // ---- Reviews ----
    @Transactional(readOnly = true)
    public Page<Review> getReviews(int page, int size) {
        return reviewRepository.findAllForAdmin(
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    public Review toggleReviewVisibility(Long reviewId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Review not found"));
        review.setVisible(!review.isVisible());
        return reviewRepository.save(review);
    }

    // ---- Promo Codes ----
    @Transactional(readOnly = true)
    public Page<PromoCode> getPromoCodes(int page, int size) {
        return promoCodeRepository.findAll(
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    public PromoCode savePromoCode(PromoCode promoCode) {
        return promoCodeRepository.save(promoCode);
    }

    public void deletePromoCode(Long id) {
        promoCodeRepository.deleteById(id);
    }

    public void togglePromoCode(Long id) {
        promoCodeRepository.findById(id).ifPresent(p -> {
            p.setActive(!p.isActive());
            promoCodeRepository.save(p);
        });
    }

    // ---- Menu ----
    @Transactional(readOnly = true)
    public List<MenuCategory> getCategoriesByRestaurant(Long restaurantId) {
        return menuCategoryRepository.findByRestaurantIdAndActiveTrueOrderByDisplayOrderAsc(restaurantId);
    }

    @Transactional(readOnly = true)
    public List<MenuItem> getItemsByCategory(Long categoryId) {
        return menuItemRepository.findByCategoryIdOrderByDisplayOrderAsc(categoryId);
    }

    public void toggleMenuItemAvailable(Long itemId) {
        menuItemRepository.findById(itemId).ifPresent(item -> {
            item.setAvailable(!item.isAvailable());
            menuItemRepository.save(item);
        });
    }
}
