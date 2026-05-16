package com.foodrush.menu.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.common.service.ImageStorageService;
import com.foodrush.menu.dto.*;
import com.foodrush.menu.service.MenuService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/v1/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
@Tag(name = "Menu", description = "Quản lý thực đơn nhà hàng")
public class MenuController {

    private final MenuService menuService;
    private final ImageStorageService imageStorageService;

    @GetMapping
    @Operation(summary = "Lấy toàn bộ menu theo danh mục")
    public ApiResponse<List<CategoryWithItemsResponse>> getMenu(@PathVariable Long restaurantId) {
        List<CategoryWithItemsResponse> categories = menuService.getMenuByRestaurant(restaurantId);
        categories.forEach(category -> {
            if (category.getItems() != null) {
                category.getItems().forEach(this::normalizeImageUrl);
            }
        });
        return ApiResponse.success(categories);
    }

    @GetMapping("/items/{itemId}")
    @Operation(summary = "Chi tiết một món ăn")
    public ApiResponse<MenuItemResponse> getItem(@PathVariable Long restaurantId, @PathVariable Long itemId) {
        MenuItemResponse item = menuService.getItemById(restaurantId, itemId);
        normalizeImageUrl(item);
        return ApiResponse.success(item);
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
        MenuItemResponse item = menuService.createItem(restaurantId, request);
        normalizeImageUrl(item);
        return ApiResponse.success(item);
    }

    @PutMapping("/items/{itemId}")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật món ăn")
    public ApiResponse<MenuItemResponse> updateItem(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId,
            @Valid @RequestBody UpdateMenuItemRequest request) {
        MenuItemResponse item = menuService.updateItem(restaurantId, itemId, request);
        normalizeImageUrl(item);
        return ApiResponse.success(item);
    }

    @PostMapping("/items/{itemId}/image")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Tải lên ảnh món ăn")
    public ApiResponse<MenuItemResponse> uploadItemImage(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId,
            @RequestParam MultipartFile imageFile) {
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh món ăn.");
        }
        String imageUrl = imageStorageService.storeImage(imageFile, "menu-items");
        MenuItemResponse item = menuService.updateItemImage(restaurantId, itemId, imageUrl);
        normalizeImageUrl(item);
        return ApiResponse.success(item, "Đã cập nhật ảnh món ăn");
    }

    @DeleteMapping("/items/{itemId}/image")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa ảnh món ăn")
    public ApiResponse<MenuItemResponse> removeItemImage(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId) {
        MenuItemResponse item = menuService.updateItemImage(restaurantId, itemId, null);
        normalizeImageUrl(item);
        return ApiResponse.success(item, "Đã xóa ảnh món ăn");
    }

    @DeleteMapping("/items/{itemId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa (ẩn) món ăn")
    public void deleteItem(@PathVariable Long restaurantId, @PathVariable Long itemId) {
        menuService.deleteItem(restaurantId, itemId);
    }

    private void normalizeImageUrl(MenuItemResponse item) {
        if (item == null) {
            return;
        }
        item.setImageUrl(toAbsoluteMediaUrl(item.getImageUrl()));
    }

    private String toAbsoluteMediaUrl(String rawUrl) {
        if (!StringUtils.hasText(rawUrl)) {
            return rawUrl;
        }
        String trimmed = rawUrl.trim();
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }
        String normalizedPath = trimmed.startsWith("/") ? trimmed : "/" + trimmed;
        return ServletUriComponentsBuilder
                .fromCurrentContextPath()
                .path(normalizedPath)
                .toUriString();
    }
}
