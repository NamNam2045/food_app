package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import com.foodrush.common.service.ImageStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
public class AdminMenuController {

    private final AdminService adminService;
    private final ImageStorageService imageStorageService;

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
        adminService.toggleMenuItemAvailable(itemId, restaurantId);
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái món ăn");
        return "redirect:/admin/restaurants/" + restaurantId + "/menu";
    }

    @PostMapping("/items/{itemId}/image")
    public String uploadItemImage(@PathVariable Long restaurantId,
                                  @PathVariable Long itemId,
                                  @RequestParam(required = false) MultipartFile imageFile,
                                  RedirectAttributes ra) {
        if (imageFile == null || imageFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh món ăn.");
            return "redirect:/admin/restaurants/" + restaurantId + "/menu";
        }

        try {
            String imageUrl = imageStorageService.storeImage(imageFile, "menu-items");
            adminService.updateMenuItemImage(itemId, restaurantId, imageUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật ảnh món ăn.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy món ăn cần cập nhật ảnh.");
        }

        return "redirect:/admin/restaurants/" + restaurantId + "/menu";
    }

    @PostMapping("/items/{itemId}/image/remove")
    public String removeItemImage(@PathVariable Long restaurantId,
                                  @PathVariable Long itemId,
                                  RedirectAttributes ra) {
        try {
            adminService.updateMenuItemImage(itemId, restaurantId, null);
            ra.addFlashAttribute("successMsg", "Đã xóa ảnh món ăn.");
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy món ăn cần xóa ảnh.");
        }
        return "redirect:/admin/restaurants/" + restaurantId + "/menu";
    }
}
