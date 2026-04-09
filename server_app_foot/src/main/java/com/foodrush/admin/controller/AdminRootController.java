package com.foodrush.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/admin")
public class AdminRootController {

    @GetMapping({"", "/"})
    public String root() {
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/login")
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "logout", required = false) String logout,
                            Model model) {
        if (error != null) {
            model.addAttribute("errorMessage", "Email hoặc mật khẩu không đúng");
        }
        if (logout != null) {
            model.addAttribute("logoutMessage", "Đăng xuất thành công");
        }
        return "admin/login";
    }
}
