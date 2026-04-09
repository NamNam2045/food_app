package com.foodrush.review.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;
import java.util.Map;

@Data @Builder
public class RestaurantReviewsResponse {
    private Double averageRating;
    private Long totalReviews;
    private Map<Integer, Long> ratingDistribution;
    private List<ReviewResponse> reviews;
    private long totalElements;
    private int totalPages;
    private int currentPage;
}
