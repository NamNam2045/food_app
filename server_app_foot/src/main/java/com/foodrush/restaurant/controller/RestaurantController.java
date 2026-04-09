package com.foodrush.restaurant.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.common.dto.PageResponse;
import com.foodrush.restaurant.dto.*;
import com.foodrush.restaurant.service.RestaurantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/restaurants")
@RequiredArgsConstructor
@Tag(name = "Restaurants", description = "Quản lý nhà hàng")
public class RestaurantController {

    private final RestaurantService restaurantService;

    @GetMapping
    @Operation(summary = "Danh sách nhà hàng với filter, khoảng cách và phân trang")
    public ApiResponse<PageResponse<RestaurantSummaryResponse>> getRestaurants(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String cuisineType,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Boolean isOpen,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) Double maxDistanceKm,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "rating") String sortBy) {
        return ApiResponse.success(restaurantService.getRestaurants(
                city, cuisineType, search, isOpen, lat, lng, maxDistanceKm, page, size, sortBy));
    }

    @GetMapping("/{idOrSlug}")
    @Operation(summary = "Chi tiết nhà hàng theo ID hoặc slug")
    public ApiResponse<RestaurantResponse> getRestaurant(@PathVariable String idOrSlug) {
        try {
            Long id = Long.parseLong(idOrSlug);
            return ApiResponse.success(restaurantService.getById(id));
        } catch (NumberFormatException e) {
            return ApiResponse.success(restaurantService.getBySlug(idOrSlug));
        }
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Tạo nhà hàng mới")
    public ApiResponse<RestaurantResponse> createRestaurant(
            @Valid @RequestBody CreateRestaurantRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(restaurantService.create(request, user.getId()), "Nhà hàng đã được tạo");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật thông tin nhà hàng")
    public ApiResponse<RestaurantResponse> updateRestaurant(
            @PathVariable Long id,
            @Valid @RequestBody UpdateRestaurantRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(restaurantService.update(id, request, user.getId()));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    @Operation(summary = "Xóa nhà hàng")
    public void deleteRestaurant(@PathVariable Long id) {
        restaurantService.delete(id);
    }
}
