package com.foodrush.menu.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class UpdateMenuItemRequest {
    private Long categoryId;
    private String name;
    private String description;
    private BigDecimal price;
    private String imageUrl;
    private Boolean available;
    private Boolean featured;
    private Integer calories;
    private Integer preparationTimeMinutes;
    private Integer displayOrder;
}
