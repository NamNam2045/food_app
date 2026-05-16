package com.foodrush.user.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.dto.ApiResponse;
import com.foodrush.common.service.ImageStorageService;
import com.foodrush.user.dto.*;
import com.foodrush.user.dto.UpdateFcmTokenRequest;
import com.foodrush.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Users", description = "Quản lý hồ sơ và địa chỉ người dùng")
public class UserController {

    private final UserService userService;
    private final ImageStorageService imageStorageService;

    @GetMapping("/me")
    @Operation(summary = "Lấy thông tin profile")
    public ApiResponse<UserProfileResponse> getProfile(@AuthenticationPrincipal UserPrincipal user) {
        UserProfileResponse response = userService.getProfile(user.getId());
        normalizeMediaUrls(response);
        return ApiResponse.success(response);
    }

    @PutMapping("/me")
    @Operation(summary = "Cập nhật profile")
    public ApiResponse<UserProfileResponse> updateProfile(
            @AuthenticationPrincipal UserPrincipal user,
            @Valid @RequestBody UpdateProfileRequest request) {
        UserProfileResponse response = userService.updateProfile(user.getId(), request);
        normalizeMediaUrls(response);
        return ApiResponse.success(response);
    }

    @PostMapping("/me/avatar")
    @Operation(summary = "Tải lên avatar profile")
    public ApiResponse<UserProfileResponse> uploadAvatar(
            @AuthenticationPrincipal UserPrincipal user,
            @RequestParam MultipartFile avatarFile) {
        if (avatarFile == null || avatarFile.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh avatar.");
        }
        String avatarUrl = imageStorageService.storeImage(avatarFile, "avatars");
        UserProfileResponse response = userService.updateProfileAvatar(user.getId(), avatarUrl);
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã cập nhật avatar");
    }

    @DeleteMapping("/me/avatar")
    @Operation(summary = "Xóa avatar profile")
    public ApiResponse<UserProfileResponse> removeAvatar(
            @AuthenticationPrincipal UserPrincipal user) {
        UserProfileResponse response = userService.removeProfileAvatar(user.getId());
        normalizeMediaUrls(response);
        return ApiResponse.success(response, "Đã xóa avatar");
    }

    @GetMapping("/me/addresses")
    @Operation(summary = "Lấy danh sách địa chỉ")
    public ApiResponse<List<AddressResponse>> getAddresses(@AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(userService.getAddresses(user.getId()));
    }

    @PostMapping("/me/addresses")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Thêm địa chỉ mới")
    public ApiResponse<AddressResponse> addAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @Valid @RequestBody AddressRequest request) {
        return ApiResponse.success(userService.addAddress(user.getId(), request));
    }

    @PutMapping("/me/addresses/{addressId}")
    @Operation(summary = "Cập nhật địa chỉ")
    public ApiResponse<AddressResponse> updateAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long addressId,
            @Valid @RequestBody AddressRequest request) {
        return ApiResponse.success(userService.updateAddress(user.getId(), addressId, request));
    }

    @DeleteMapping("/me/addresses/{addressId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Xóa địa chỉ")
    public void deleteAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long addressId) {
        userService.deleteAddress(user.getId(), addressId);
    }

    @PutMapping("/me/fcm-token")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Cập nhật FCM token cho push notification")
    public void updateFcmToken(
            @AuthenticationPrincipal UserPrincipal user,
            @Valid @RequestBody UpdateFcmTokenRequest request) {
        userService.updateFcmToken(user.getId(), request.getFcmToken());
    }

    private void normalizeMediaUrls(UserProfileResponse response) {
        if (response == null) {
            return;
        }
        response.setProfilePictureUrl(toAbsoluteMediaUrl(response.getProfilePictureUrl()));
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
