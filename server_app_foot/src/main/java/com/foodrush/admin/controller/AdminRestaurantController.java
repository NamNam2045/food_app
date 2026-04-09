package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/restaurants")
@RequiredArgsConstructor
public class AdminRestaurantController {

    private final AdminService adminService;

    @GetMapping
    public String list(@RequestParam(required = false) String search,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        model.addAttribute("restaurants", adminService.getRestaurants(search, page, 20));
        model.addAttribute("search", search);
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "restaurants");
        return "admin/restaurants/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        var restaurant = adminService.getRestaurantById(id)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("categories", adminService.getCategoriesByRestaurant(id));
        model.addAttribute("activePage", "restaurants");
        return "admin/restaurants/detail";
    }

    @PostMapping("/{id}/toggle-open")
    public String toggleOpen(@PathVariable Long id, RedirectAttributes ra) {
        var r = adminService.toggleRestaurantOpen(id);
        ra.addFlashAttribute("successMsg",
                "Nhà hàng \"" + r.getName() + "\" hiện đang " + (r.isOpen() ? "MỞ CỬA" : "ĐÓNG CỬA"));
        return "redirect:/admin/restaurants";
    }

    @PostMapping("/{id}/toggle-active")
    public String toggleActive(@PathVariable Long id, RedirectAttributes ra) {
        var r = adminService.toggleRestaurantActive(id);
        ra.addFlashAttribute("successMsg",
                "Đã " + (r.isActive() ? "kích hoạt" : "vô hiệu hóa") + " nhà hàng: " + r.getName());
        return "redirect:/admin/restaurants";
    }
}
