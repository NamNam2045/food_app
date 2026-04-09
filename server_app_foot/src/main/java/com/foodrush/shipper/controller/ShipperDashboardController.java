package com.foodrush.shipper.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.shipper.service.ShipperService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shipper/dashboard")
@RequiredArgsConstructor
public class ShipperDashboardController {

    private final ShipperService shipperService;

    @GetMapping
    public String dashboard(@AuthenticationPrincipal UserPrincipal principal, Model model) {
        model.addAttribute("stats", shipperService.getDashboardStats(principal.getId()));
        model.addAttribute("activePage", "dashboard");
        return "shipper/dashboard";
    }
}
