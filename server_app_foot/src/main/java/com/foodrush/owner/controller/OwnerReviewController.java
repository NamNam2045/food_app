package com.foodrush.owner.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.owner.service.OwnerService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/owner/reviews")
@RequiredArgsConstructor
public class OwnerReviewController {

    private final OwnerService ownerService;

    @GetMapping
    public String list(@AuthenticationPrincipal UserPrincipal principal,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        Restaurant restaurant = ownerService.getRestaurantByOwner(principal.getId())
                .orElseThrow(() -> new RuntimeException("No restaurant found"));
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("reviews", ownerService.getReviews(restaurant.getId(), page, 20));
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "reviews");
        return "owner/reviews/list";
    }
}
