package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminService adminService;

    @GetMapping
    public String list(@RequestParam(required = false) String search,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        model.addAttribute("users", adminService.getUsers(search, page, 20));
        model.addAttribute("search", search);
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "users");
        return "admin/users/list";
    }

    @PostMapping("/{userId}/toggle-active")
    public String toggleActive(@PathVariable Long userId, RedirectAttributes ra) {
        var user = adminService.toggleUserActive(userId);
        ra.addFlashAttribute("successMsg",
                "Đã " + (user.isActive() ? "kích hoạt" : "vô hiệu hóa") + " tài khoản: " + user.getEmail());
        return "redirect:/admin/users";
    }
}
