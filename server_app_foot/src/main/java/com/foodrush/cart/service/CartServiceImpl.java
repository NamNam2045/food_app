package com.foodrush.cart.service;

import com.foodrush.cart.dto.*;
import com.foodrush.cart.entity.Cart;
import com.foodrush.cart.entity.CartItem;
import com.foodrush.cart.repository.CartItemRepository;
import com.foodrush.cart.repository.CartRepository;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.menu.entity.MenuItem;
import com.foodrush.menu.repository.MenuItemRepository;
import com.foodrush.user.entity.User;
import com.foodrush.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CartServiceImpl implements CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final MenuItemRepository menuItemRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public CartResponse getCart(Long userId) {
        Optional<Cart> cart = cartRepository.findByUserIdWithItems(userId);
        if (cart.isEmpty()) return emptyCartResponse();
        return toCartResponse(cart.get());
    }

    @Override
    @Transactional(readOnly = true)
    public Cart getCartByUserId(Long userId) {
        return cartRepository.findByUserIdWithItems(userId)
                .orElseThrow(() -> new BusinessRuleException("CART_001", "Giỏ hàng trống"));
    }

    @Override
    public CartResponse addItem(Long userId, AddToCartRequest request) {
        MenuItem menuItem = menuItemRepository.findById(request.getMenuItemId())
                .orElseThrow(() -> new ResourceNotFoundException("Món ăn không tồn tại"));

        if (!menuItem.isAvailable()) {
            throw new BusinessRuleException("CART_002", "Món ăn này hiện không có sẵn");
        }

        Cart cart = cartRepository.findByUserId(userId).orElseGet(() -> {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));
            Cart newCart = Cart.builder().user(user).restaurant(menuItem.getRestaurant()).build();
            return cartRepository.save(newCart);
        });

        // Kiểm tra xung đột nhà hàng
        if (cart.getRestaurant() != null && !cart.getRestaurant().getId().equals(menuItem.getRestaurant().getId())) {
            throw new BusinessRuleException("CART_003",
                    "Giỏ hàng đang có món từ nhà hàng khác. Vui lòng xóa giỏ hàng trước khi thêm món mới.");
        }

        if (cart.getRestaurant() == null) {
            cart.setRestaurant(menuItem.getRestaurant());
        }

        // Tìm item đã có trong giỏ
        Optional<CartItem> existingItem = cartItemRepository.findByCartIdAndMenuItemId(cart.getId(), menuItem.getId());
        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(item.getQuantity() + request.getQuantity());
            cartItemRepository.save(item);
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart).menuItem(menuItem).quantity(request.getQuantity())
                    .unitPrice(menuItem.getPrice()).specialInstructions(request.getSpecialInstructions())
                    .build();
            cart.getItems().add(cartItemRepository.save(newItem));
        }

        return toCartResponse(cartRepository.findByUserIdWithItems(userId).orElse(cart));
    }

    @Override
    public CartResponse updateItem(Long userId, Long cartItemId, UpdateCartItemRequest request) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Giỏ hàng không tồn tại"));

        CartItem item = cartItemRepository.findById(cartItemId)
                .filter(ci -> ci.getCart().getId().equals(cart.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Mục giỏ hàng không tồn tại"));

        if (request.getQuantity() == 0) {
            cartItemRepository.delete(item);
        } else {
            item.setQuantity(request.getQuantity());
            cartItemRepository.save(item);
        }

        Cart updated = cartRepository.findByUserIdWithItems(userId).orElse(cart);
        if (updated.getItems().isEmpty()) {
            updated.setRestaurant(null);
            cartRepository.save(updated);
        }
        return toCartResponse(updated);
    }

    @Override
    public CartResponse removeItem(Long userId, Long cartItemId) {
        return updateItem(userId, cartItemId, buildUpdateRequest(0));
    }

    @Override
    public void clearCart(Long userId) {
        cartRepository.findByUserId(userId).ifPresent(cart -> {
            cart.getItems().clear();
            cart.setRestaurant(null);
            cartRepository.save(cart);
        });
    }

    private CartResponse toCartResponse(Cart cart) {
        List<CartItemResponse> items = cart.getItems().stream()
                .map(ci -> CartItemResponse.builder()
                        .id(ci.getId()).menuItemId(ci.getMenuItem().getId())
                        .menuItemName(ci.getMenuItem().getName())
                        .menuItemImageUrl(ci.getMenuItem().getImageUrl())
                        .quantity(ci.getQuantity()).unitPrice(ci.getUnitPrice())
                        .subtotal(ci.getUnitPrice().multiply(BigDecimal.valueOf(ci.getQuantity())))
                        .specialInstructions(ci.getSpecialInstructions())
                        .build())
                .collect(Collectors.toList());

        BigDecimal subtotal = items.stream()
                .map(CartItemResponse::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal deliveryFee = cart.getRestaurant() != null ? cart.getRestaurant().getDeliveryFee() : BigDecimal.ZERO;

        return CartResponse.builder()
                .id(cart.getId())
                .restaurantId(cart.getRestaurant() != null ? cart.getRestaurant().getId() : null)
                .restaurantName(cart.getRestaurant() != null ? cart.getRestaurant().getName() : null)
                .items(items).itemCount(items.size())
                .subtotal(subtotal).deliveryFee(deliveryFee).total(subtotal.add(deliveryFee))
                .build();
    }

    private CartResponse emptyCartResponse() {
        return CartResponse.builder().items(List.of()).itemCount(0)
                .subtotal(BigDecimal.ZERO).deliveryFee(BigDecimal.ZERO).total(BigDecimal.ZERO).build();
    }

    private UpdateCartItemRequest buildUpdateRequest(int qty) {
        UpdateCartItemRequest r = new UpdateCartItemRequest();
        r.setQuantity(qty);
        return r;
    }
}
