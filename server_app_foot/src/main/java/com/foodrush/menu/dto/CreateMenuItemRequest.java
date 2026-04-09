package com.foodrush.menu.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class CreateMenuItemRequest {
    @NotNull private Long categoryId;
    @NotBlank private String name;
    private String description;
    @NotNull @DecimalMin("0.01") private BigDecimal price;
    private String imageUrl;
    private boolean available = true;
    private boolean featured = false;
    private Integer calories;
    private Integer preparationTimeMinutes = 15;
    private Integer displayOrder = 0;
}
