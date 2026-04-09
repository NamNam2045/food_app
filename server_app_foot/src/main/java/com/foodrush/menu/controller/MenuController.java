package com.foodrush.menu.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.menu.dto.*;
import com.foodrush.menu.service.MenuService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
@Tag(name = "Menu", description = "Quản lý thực đơn nhà hàng")
public class MenuController {

    private final MenuService menuService;

    @GetMapping
    @Operation(summary = "Lấy toàn bộ menu theo danh mục")
    public ApiResponse<List<CategoryWithItemsResponse>> getMenu(@PathVariable Long restaurantId) {
        return ApiResponse.success(menuService.getMenuByRestaurant(restaurantId));
    }

    @GetMapping("/items/{itemId}")
    @Operation(summary = "Chi tiết một món ăn")
    public ApiResponse<MenuItemResponse> getItem(@PathVariable Long restaurantId, @PathVariable Long itemId) {
        return ApiResponse.success(menuService.getItemById(restaurantId, itemId));
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Thêm danh mục menu")
    public ApiResponse<CategoryWithItemsResponse> createCategory(
            @PathVariable Long restaurantId,
            @Valid @RequestBody CreateCategoryRequest request) {
        return ApiResponse.success(menuService.createCategory(restaurantId, request));
    }

    @PutMapping("/categories/{categoryId}")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật danh mục menu")
    public ApiResponse<CategoryWithItemsResponse> updateCategory(
            @PathVariable Long restaurantId,
            @PathVariable Long categoryId,
            @RequestBody UpdateCategoryRequest request) {
        return ApiResponse.success(menuService.updateCategory(restaurantId, categoryId, request));
    }

    @DeleteMapping("/categories/{categoryId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa (ẩn) danh mục và toàn bộ món bên trong")
    public void deleteCategory(@PathVariable Long restaurantId, @PathVariable Long categoryId) {
        menuService.deleteCategory(restaurantId, categoryId);
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Thêm món ăn vào menu")
    public ApiResponse<MenuItemResponse> createItem(
            @PathVariable Long restaurantId,
            @Valid @RequestBody CreateMenuItemRequest request) {
        return ApiResponse.success(menuService.createItem(restaurantId, request));
    }

    @PutMapping("/items/{itemId}")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật món ăn")
    public ApiResponse<MenuItemResponse> updateItem(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId,
            @Valid @RequestBody UpdateMenuItemRequest request) {
        return ApiResponse.success(menuService.updateItem(restaurantId, itemId, request));
    }

    @DeleteMapping("/items/{itemId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa (ẩn) món ăn")
    public void deleteItem(@PathVariable Long restaurantId, @PathVariable Long itemId) {
        menuService.deleteItem(restaurantId, itemId);
    }
}
