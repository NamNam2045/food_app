package com.foodrush.restaurant.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.common.dto.PageResponse;
import com.foodrush.common.service.ImageStorageService;
import com.foodrush.restaurant.dto.*;
import com.foodrush.restaurant.service.RestaurantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/api/v1/restaurants")
@RequiredArgsConstructor
@Tag(name = "Restaurants", description = "Quản lý nhà hàng")
public class RestaurantController {

    private final RestaurantService restaurantService;
    private final ImageStorageService imageStorageService;

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
        PageResponse<RestaurantSummaryResponse> response = restaurantService.getRestaurants(
                city, cuisineType, search, isOpen, lat, lng, maxDistanceKm, page, size, sortBy);
        if (response.getContent() != null) {
            response.getContent().forEach(this::normalizeMediaUrls);
        }
        return ApiResponse.success(response);
    }

    @GetMapping("/{idOrSlug}")
    @Operation(summary = "Chi tiết nhà hàng theo ID hoặc slug")
    public ApiResponse<RestaurantResponse> getRestaurant(@PathVariable String idOrSlug) {
        try {
            Long id = Long.parseLong(idOrSlug);
            RestaurantResponse response = restaurantService.getById(id);
            normalizeMediaUrls(response);
            return ApiResponse.success(response);
        } catch (NumberFormatException e) {
            RestaurantResponse response = restaurantService.getBySlug(idOrSlug);
            normalizeMediaUrls(response);
            return ApiResponse.success(response);
        }
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Tạo nhà hàng mới")
    public ApiResponse<RestaurantResponse> createRestaurant(
            @Valid @RequestBody CreateRestaurantRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        RestaurantResponse response = restaurantService.create(request, user.getId());
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Nhà hàng đã được tạo");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Cập nhật thông tin nhà hàng")
    public ApiResponse<RestaurantResponse> updateRestaurant(
            @PathVariable Long id,
            @Valid @RequestBody UpdateRestaurantRequest request,
            @AuthenticationPrincipal UserPrincipal user) {
        RestaurantResponse response = restaurantService.update(id, request, user.getId());
        normalizeMediaUrls(response);
        return ApiResponse.success(response);
    }

    @PostMapping("/{id}/logo")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Upload logo nhà hàng")
    public ApiResponse<RestaurantResponse> uploadLogo(
            @PathVariable Long id,
            @RequestParam MultipartFile imageFile,
            @AuthenticationPrincipal UserPrincipal user) {
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh logo.");
        }
        String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-logos");
        RestaurantResponse response = restaurantService.updateLogo(id, imageUrl, user.getId(), isSystemAdmin(user));
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã cập nhật logo nhà hàng");
    }

    @DeleteMapping("/{id}/logo")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa logo nhà hàng")
    public ApiResponse<RestaurantResponse> removeLogo(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal user) {
        RestaurantResponse response = restaurantService.updateLogo(id, null, user.getId(), isSystemAdmin(user));
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã xóa logo nhà hàng");
    }

    @PostMapping("/{id}/banner")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Upload banner nhà hàng")
    public ApiResponse<RestaurantResponse> uploadBanner(
            @PathVariable Long id,
            @RequestParam MultipartFile imageFile,
            @AuthenticationPrincipal UserPrincipal user) {
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh banner.");
        }
        String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-banners");
        RestaurantResponse response = restaurantService.updateBanner(id, imageUrl, user.getId(), isSystemAdmin(user));
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã cập nhật banner nhà hàng");
    }

    @DeleteMapping("/{id}/banner")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'SYSTEM_ADMIN')")
    @Operation(summary = "Xóa banner nhà hàng")
    public ApiResponse<RestaurantResponse> removeBanner(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal user) {
        RestaurantResponse response = restaurantService.updateBanner(id, null, user.getId(), isSystemAdmin(user));
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã xóa banner nhà hàng");
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    @Operation(summary = "Xóa nhà hàng")
    public void deleteRestaurant(@PathVariable Long id) {
        restaurantService.delete(id);
    }

    private boolean isSystemAdmin(UserPrincipal user) {
        return user.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch("ROLE_SYSTEM_ADMIN"::equals);
    }

    private void normalizeMediaUrls(RestaurantSummaryResponse response) {
        if (response == null) {
            return;
        }
        response.setLogoUrl(toAbsoluteMediaUrl(response.getLogoUrl()));
        response.setBannerUrl(toAbsoluteMediaUrl(response.getBannerUrl()));
    }

    private void normalizeMediaUrls(RestaurantResponse response) {
        if (response == null) {
            return;
        }
        response.setLogoUrl(toAbsoluteMediaUrl(response.getLogoUrl()));
        response.setBannerUrl(toAbsoluteMediaUrl(response.getBannerUrl()));
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
