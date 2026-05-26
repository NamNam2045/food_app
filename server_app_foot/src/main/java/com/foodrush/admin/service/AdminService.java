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
import com.foodrush.common.enums.UserRole;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;

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
    private final PasswordEncoder passwordEncoder;

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

    /** Tạo tài khoản mới với role bất kỳ (CUSTOMER, RESTAURANT_ADMIN, DELIVERY_AGENT, SYSTEM_ADMIN). */
    public User createUser(String email, String phoneNumber, String rawPassword,
                           String firstName, String lastName, UserRole role) {
        if (email == null || email.isBlank()) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Email không được để trống");
        }
        if (rawPassword == null || rawPassword.length() < 8) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Mật khẩu phải có ít nhất 8 ký tự");
        }
        String normalizedEmail = email.trim().toLowerCase();
        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new BusinessRuleException("USER_001", "Email đã tồn tại");
        }
        if (phoneNumber != null && !phoneNumber.isBlank()
                && userRepository.existsByPhoneNumber(phoneNumber.trim())) {
            throw new BusinessRuleException("USER_002", "Số điện thoại đã được dùng");
        }
        if (role == null) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Vai trò không được để trống");
        }

        User user = User.builder()
                .email(normalizedEmail)
                .phoneNumber(phoneNumber == null || phoneNumber.isBlank() ? null : phoneNumber.trim())
                .passwordHash(passwordEncoder.encode(rawPassword))
                .firstName(firstName == null ? "" : firstName.trim())
                .lastName(lastName == null ? "" : lastName.trim())
                .role(role)
                .active(true)
                .emailVerified(true)
                .build();
        return userRepository.save(user);
    }

    public User updateUserAvatar(Long userId, String avatarUrl) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setProfilePictureUrl(avatarUrl);
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

    /** Lấy danh sách user có role RESTAURANT_ADMIN để chọn làm chủ nhà hàng. */
    @Transactional(readOnly = true)
    public List<User> getAvailableOwners() {
        return userRepository.findAll().stream()
                .filter(u -> u.getRole() == UserRole.RESTAURANT_ADMIN && u.isActive())
                .sorted((a, b) -> a.getEmail().compareToIgnoreCase(b.getEmail()))
                .toList();
    }

    /** Tạo nhà hàng mới và gán cho một owner (user có role RESTAURANT_ADMIN). */
    public Restaurant createRestaurant(Long ownerId, String name, String cuisineType,
                                       String streetAddress, String city,
                                       String description, String phone, String email,
                                       BigDecimal minOrderAmount, BigDecimal deliveryFee,
                                       Integer estimatedDeliveryMinutes) {
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Tên nhà hàng không được để trống");
        }
        if (cuisineType == null || cuisineType.isBlank()) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Loại ẩm thực không được để trống");
        }
        if (streetAddress == null || streetAddress.isBlank() || city == null || city.isBlank()) {
            throw new BusinessRuleException("VALIDATION_ERROR", "Địa chỉ không được để trống");
        }
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new ResourceNotFoundException("Owner không tồn tại"));
        if (owner.getRole() != UserRole.RESTAURANT_ADMIN) {
            throw new BusinessRuleException("VALIDATION_ERROR",
                    "Chủ sở hữu phải có vai trò RESTAURANT_ADMIN");
        }

        String slug = generateUniqueSlug(name);

        Restaurant restaurant = Restaurant.builder()
                .owner(owner)
                .name(name.trim())
                .slug(slug)
                .description(description)
                .cuisineType(cuisineType.trim())
                .phone(phone)
                .email(email)
                .streetAddress(streetAddress.trim())
                .city(city.trim())
                .minOrderAmount(minOrderAmount == null ? BigDecimal.ZERO : minOrderAmount)
                .deliveryFee(deliveryFee == null ? BigDecimal.ZERO : deliveryFee)
                .estimatedDeliveryMinutes(estimatedDeliveryMinutes == null ? 30 : estimatedDeliveryMinutes)
                .active(true)
                .open(false)
                .build();
        return restaurantRepository.save(restaurant);
    }

    private String generateUniqueSlug(String name) {
        String base = Normalizer.normalize(name, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .toLowerCase()
                .replaceAll("đ", "d")
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        if (base.isBlank()) base = "restaurant";
        String slug = base;
        int suffix = 2;
        while (restaurantRepository.findBySlug(slug).isPresent()) {
            slug = base + "-" + suffix;
            suffix++;
        }
        return slug;
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

    public Restaurant updateRestaurantLogo(Long restaurantId, String logoUrl) {
        Restaurant r = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        r.setLogoUrl(logoUrl);
        return restaurantRepository.save(r);
    }

    public Restaurant updateRestaurantBanner(Long restaurantId, String bannerUrl) {
        Restaurant r = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        r.setBannerUrl(bannerUrl);
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

    public void toggleMenuItemAvailable(Long itemId, Long restaurantId) {
        MenuItem item = menuItemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new RuntimeException("Menu item not found"));
        item.setAvailable(!item.isAvailable());
        menuItemRepository.save(item);
    }

    public void updateMenuItemImage(Long itemId, Long restaurantId, String imageUrl) {
        MenuItem item = menuItemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new RuntimeException("Menu item not found"));
        item.setImageUrl(imageUrl);
        menuItemRepository.save(item);
    }
}
