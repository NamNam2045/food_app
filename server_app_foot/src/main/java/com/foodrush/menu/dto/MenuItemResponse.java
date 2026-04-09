package com.foodrush.menu.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data @Builder
public class MenuItemResponse {
    private Long id;
    private Long categoryId;
    private String name;
    private String description;
    private BigDecimal price;
    private String imageUrl;
    private boolean available;
    private boolean featured;
    private Integer calories;
    private Integer preparationTimeMinutes;
    private Integer displayOrder;
}
