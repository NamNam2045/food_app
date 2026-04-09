package com.foodrush.menu.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data @Builder
public class CategoryWithItemsResponse {
    private Long id;
    private String name;
    private String description;
    private Integer displayOrder;
    private List<MenuItemResponse> items;
}
