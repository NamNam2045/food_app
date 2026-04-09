package com.foodrush.owner.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.owner.service.OwnerService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/owner/menu")
@RequiredArgsConstructor
public class OwnerMenuController {

    private final OwnerService ownerService;

    private Restaurant getRestaurantOrThrow(Long ownerId) {
        return ownerService.getRestaurantByOwner(ownerId)
                .orElseThrow(() -> new RuntimeException("No restaurant found for this owner"));
    }

    @GetMapping
    public String list(@AuthenticationPrincipal UserPrincipal principal, Model model) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        var categories = ownerService.getCategories(restaurant.getId());

        model.addAttribute("restaurant", restaurant);
        model.addAttribute("categories", categories);
        // build map categoryId -> items
        var itemMap = new java.util.LinkedHashMap<Long, java.util.List<com.foodrush.menu.entity.MenuItem>>();
        categories.forEach(cat ->
                itemMap.put(cat.getId(), ownerService.getItemsByCategory(cat.getId())));
        model.addAttribute("itemMap", itemMap);
        model.addAttribute("activePage", "menu");
        return "owner/menu/list";
    }

    @PostMapping("/items/{itemId}/toggle")
    public String toggleItem(@PathVariable Long itemId,
                             @AuthenticationPrincipal UserPrincipal principal,
                             RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.toggleItemAvailable(itemId, restaurant.getId());
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái món ăn.");
        return "redirect:/owner/menu";
    }
}
