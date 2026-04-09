package com.foodrush.cart.service;

import com.foodrush.cart.dto.*;
import com.foodrush.cart.entity.Cart;

public interface CartService {
    CartResponse getCart(Long userId);
    Cart getCartByUserId(Long userId);
    CartResponse addItem(Long userId, AddToCartRequest request);
    CartResponse updateItem(Long userId, Long cartItemId, UpdateCartItemRequest request);
    CartResponse removeItem(Long userId, Long cartItemId);
    void clearCart(Long userId);
}
