package com.foodrush.review.service;

import com.foodrush.review.dto.*;

public interface ReviewService {
    ReviewResponse createReview(CreateReviewRequest request, Long userId);
    RestaurantReviewsResponse getRestaurantReviews(Long restaurantId, int page, int size);
}
