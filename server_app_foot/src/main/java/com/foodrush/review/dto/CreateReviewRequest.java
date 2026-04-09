package com.foodrush.review.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class CreateReviewRequest {
    @NotNull private Long orderId;
    @NotNull @Min(1) @Max(5) private Integer rating;
    private String comment;
}
