package com.foodrush.menu.dto;

import lombok.Data;

@Data
public class UpdateCategoryRequest {
    private String name;
    private String description;
    private Integer displayOrder;
    private Boolean active;
}
