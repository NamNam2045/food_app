package com.foodrush.owner.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.owner.service.OwnerService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/owner/dashboard")
@RequiredArgsConstructor
public class OwnerDashboardController {

    private final OwnerService ownerService;

    @GetMapping
    public String dashboard(@AuthenticationPrincipal UserPrincipal principal,
                            Model model, RedirectAttributes ra) {
        Restaurant restaurant = ownerService.getRestaurantByOwner(principal.getId())
                .orElse(null);
        if (restaurant == null) {
            ra.addFlashAttribute("errorMsg", "Bạn chưa có nhà hàng nào trong hệ thống.");
            model.addAttribute("activePage", "dashboard");
            model.addAttribute("restaurant", null);
            return "owner/dashboard";
        }
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("stats", ownerService.getDashboardStats(restaurant.getId()));
        model.addAttribute("activePage", "dashboard");
        return "owner/dashboard";
    }
}
