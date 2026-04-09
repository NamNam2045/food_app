package com.foodrush.review.service;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.order.entity.Order;
import com.foodrush.order.repository.OrderRepository;
import com.foodrush.restaurant.entity.Restaurant;
import com.foodrush.restaurant.repository.RestaurantRepository;
import com.foodrush.review.dto.*;
import com.foodrush.review.entity.Review;
import com.foodrush.review.repository.ReviewRepository;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final OrderRepository orderRepository;
    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;

    @Override
    public ReviewResponse createReview(CreateReviewRequest request, Long userId) {
        Order order = orderRepository.findById(request.getOrderId())
                .filter(o -> o.getUser().getId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));

        if (order.getStatus() != OrderStatus.DELIVERED) {
            throw new BusinessRuleException("REVIEW_001", "Chỉ có thể đánh giá đơn hàng đã được giao");
        }

        if (reviewRepository.existsByOrderId(order.getId())) {
            throw new BusinessRuleException("REVIEW_002", "Bạn đã đánh giá đơn hàng này rồi");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));

        Review review = Review.builder()
                .order(order).user(user).restaurant(order.getRestaurant())
                .rating(request.getRating()).comment(request.getComment()).build();

        review = reviewRepository.save(review);
        updateRestaurantRating(order.getRestaurant());
        return toResponse(review);
    }

    @Override
    @Transactional(readOnly = true)
    public RestaurantReviewsResponse getRestaurantReviews(Long restaurantId, int page, int size) {
        Page<Review> reviewPage = reviewRepository.findByRestaurantIdAndVisibleTrue(
                restaurantId, PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));

        Double avg = reviewRepository.findAverageRatingByRestaurantId(restaurantId);
        Long total = reviewRepository.countByRestaurantId(restaurantId);

        Map<Integer, Long> distribution = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            final int rating = i;
            long count = reviewPage.getContent().stream().filter(r -> r.getRating() == rating).count();
            distribution.put(i, count);
        }

        List<ReviewResponse> reviews = reviewPage.getContent().stream()
                .map(this::toResponse).collect(Collectors.toList());

        return RestaurantReviewsResponse.builder()
                .averageRating(avg != null ? BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP).doubleValue() : 0.0)
                .totalReviews(total != null ? total : 0L)
                .ratingDistribution(distribution).reviews(reviews)
                .totalElements(reviewPage.getTotalElements())
                .totalPages(reviewPage.getTotalPages()).currentPage(reviewPage.getNumber())
                .build();
    }

    private void updateRestaurantRating(Restaurant restaurant) {
        Double avg = reviewRepository.findAverageRatingByRestaurantId(restaurant.getId());
        Long count = reviewRepository.countByRestaurantId(restaurant.getId());
        restaurant.setRatingAvg(avg != null ? BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO);
        restaurant.setRatingCount(count != null ? count.intValue() : 0);
        restaurantRepository.save(restaurant);
    }

    private ReviewResponse toResponse(Review r) {
        return ReviewResponse.builder()
                .id(r.getId()).orderId(r.getOrder().getId())
                .userFirstName(r.getUser().getFirstName())
                .userProfilePictureUrl(r.getUser().getProfilePictureUrl())
                .rating(r.getRating()).comment(r.getComment())
                .createdAt(r.getCreatedAt()).build();
    }
}
