package com.foodrush.review.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data @Builder
public class ReviewResponse {
    private Long id;
    private Long orderId;
    private String userFirstName;
    private String userProfilePictureUrl;
    private Integer rating;
    private String comment;
    private LocalDateTime createdAt;
}
