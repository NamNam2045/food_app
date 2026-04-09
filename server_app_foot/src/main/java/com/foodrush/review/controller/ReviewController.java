package com.foodrush.review.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.review.dto.*;
import com.foodrush.review.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "Reviews", description = "Đánh giá nhà hàng")
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/api/v1/reviews")
    @ResponseStatus(HttpStatus.CREATED)
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Tạo đánh giá cho đơn hàng đã giao")
    public ApiResponse<ReviewResponse> createReview(
            @Valid @RequestBody CreateReviewRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(reviewService.createReview(request, user.getId()), "Cảm ơn bạn đã đánh giá!");
    }

    @GetMapping("/api/v1/restaurants/{restaurantId}/reviews")
    @Operation(summary = "Danh sách đánh giá của nhà hàng")
    public ApiResponse<RestaurantReviewsResponse> getRestaurantReviews(
            @PathVariable Long restaurantId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(reviewService.getRestaurantReviews(restaurantId, page, size));
    }
}
