package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import com.foodrush.common.enums.UserRole;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.service.ImageStorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Slf4j
@Controller
@RequestMapping("/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminService adminService;
    private final ImageStorageService imageStorageService;

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

    @PostMapping("/create")
    public String create(@RequestParam String email,
                         @RequestParam(required = false) String phoneNumber,
                         @RequestParam String password,
                         @RequestParam String firstName,
                         @RequestParam String lastName,
                         @RequestParam UserRole role,
                         RedirectAttributes ra) {
        try {
            var user = adminService.createUser(email, phoneNumber, password, firstName, lastName, role);
            ra.addFlashAttribute("successMsg",
                    "Đã tạo tài khoản " + user.getEmail() + " (" + user.getRole() + ")");
        } catch (BusinessRuleException ex) {
            log.warn("Create user failed: {}", ex.getMessage());
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        }
        return "redirect:/admin/users";
    }

    @PostMapping("/{userId}/toggle-active")
    public String toggleActive(@PathVariable Long userId, RedirectAttributes ra) {
        var user = adminService.toggleUserActive(userId);
        ra.addFlashAttribute("successMsg",
                "Đã " + (user.isActive() ? "kích hoạt" : "vô hiệu hóa") + " tài khoản: " + user.getEmail());
        return "redirect:/admin/users";
    }

    @PostMapping("/{userId}/avatar")
    public String uploadAvatar(@PathVariable Long userId,
                               @RequestParam(required = false) MultipartFile avatarFile,
                               RedirectAttributes ra) {
        if (avatarFile == null || avatarFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh avatar.");
            return "redirect:/admin/users";
        }

        try {
            String avatarUrl = imageStorageService.storeImage(avatarFile, "avatars");
            var user = adminService.updateUserAvatar(userId, avatarUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật avatar cho " + user.getEmail());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        }
        return "redirect:/admin/users";
    }

    @PostMapping("/{userId}/avatar/remove")
    public String removeAvatar(@PathVariable Long userId, RedirectAttributes ra) {
        try {
            var user = adminService.updateUserAvatar(userId, null);
            ra.addFlashAttribute("successMsg", "Đã xóa avatar của " + user.getEmail());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy người dùng cần xóa avatar.");
        }
        return "redirect:/admin/users";
    }
}
