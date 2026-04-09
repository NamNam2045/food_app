package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin/dashboard")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final AdminService adminService;

    @GetMapping
    public String dashboard(Model model) {
        model.addAttribute("stats", adminService.getDashboardStats());
        model.addAttribute("recentOrders", adminService.getRecentOrders(10));
        model.addAttribute("activePage", "dashboard");
        return "admin/dashboard";
    }
}
