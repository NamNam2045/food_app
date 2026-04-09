package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
public class AdminMenuController {

    private final AdminService adminService;

    @GetMapping
    public String menu(@PathVariable Long restaurantId, Model model) {
        var restaurant = adminService.getRestaurantById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("categories", adminService.getCategoriesByRestaurant(restaurantId));
        model.addAttribute("activePage", "restaurants");
        return "admin/menu/list";
    }

    @PostMapping("/items/{itemId}/toggle")
    public String toggleItem(@PathVariable Long restaurantId,
                             @PathVariable Long itemId,
                             RedirectAttributes ra) {
        adminService.toggleMenuItemAvailable(itemId);
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái món ăn");
        return "redirect:/admin/restaurants/" + restaurantId + "/menu";
    }
}
