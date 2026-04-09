package com.foodrush.cart.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.cart.dto.*;
import com.foodrush.cart.service.CartService;
import com.foodrush.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Cart", description = "Quản lý giỏ hàng")
public class CartController {

    private final CartService cartService;

    @GetMapping
    @Operation(summary = "Lấy giỏ hàng hiện tại")
    public ApiResponse<CartResponse> getCart(@AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(cartService.getCart(user.getId()));
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Thêm món vào giỏ hàng")
    public ApiResponse<CartResponse> addItem(
            @AuthenticationPrincipal UserPrincipal user,
            @Valid @RequestBody AddToCartRequest request) {
        return ApiResponse.success(cartService.addItem(user.getId(), request));
    }

    @PutMapping("/items/{cartItemId}")
    @Operation(summary = "Cập nhật số lượng")
    public ApiResponse<CartResponse> updateItem(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long cartItemId,
            @Valid @RequestBody UpdateCartItemRequest request) {
        return ApiResponse.success(cartService.updateItem(user.getId(), cartItemId, request));
    }

    @DeleteMapping("/items/{cartItemId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Xóa một món khỏi giỏ")
    public void removeItem(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long cartItemId) {
        cartService.removeItem(user.getId(), cartItemId);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Xóa toàn bộ giỏ hàng")
    public void clearCart(@AuthenticationPrincipal UserPrincipal user) {
        cartService.clearCart(user.getId());
    }
}
