package com.foodrush.menu.service;

import com.foodrush.menu.dto.*;
import java.util.List;

public interface MenuService {
    List<CategoryWithItemsResponse> getMenuByRestaurant(Long restaurantId);
    MenuItemResponse getItemById(Long restaurantId, Long itemId);
    CategoryWithItemsResponse createCategory(Long restaurantId, CreateCategoryRequest request);
    CategoryWithItemsResponse updateCategory(Long restaurantId, Long categoryId, UpdateCategoryRequest request);
    void deleteCategory(Long restaurantId, Long categoryId);
    MenuItemResponse createItem(Long restaurantId, CreateMenuItemRequest request);
    MenuItemResponse updateItem(Long restaurantId, Long itemId, UpdateMenuItemRequest request);
    void deleteItem(Long restaurantId, Long itemId);
}
