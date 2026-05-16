package com.foodrush.owner.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.service.ImageStorageService;
import com.foodrush.owner.service.OwnerService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/owner/dashboard")
@RequiredArgsConstructor
public class OwnerDashboardController {

    private final OwnerService ownerService;
    private final ImageStorageService imageStorageService;

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

    @PostMapping("/logo")
    public String uploadLogo(@AuthenticationPrincipal UserPrincipal principal,
                             @RequestParam Long restaurantId,
                             @RequestParam(required = false) MultipartFile imageFile,
                             RedirectAttributes ra) {
        if (imageFile == null || imageFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh logo.");
            return "redirect:/owner/dashboard";
        }
        try {
            String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-logos");
            ownerService.updateRestaurantLogo(principal.getId(), restaurantId, imageUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật logo quán.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng để cập nhật logo.");
        }
        return "redirect:/owner/dashboard";
    }

    @PostMapping("/logo/remove")
    public String removeLogo(@AuthenticationPrincipal UserPrincipal principal,
                             @RequestParam Long restaurantId,
                             RedirectAttributes ra) {
        try {
            ownerService.updateRestaurantLogo(principal.getId(), restaurantId, null);
            ra.addFlashAttribute("successMsg", "Đã xóa logo quán.");
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng để xóa logo.");
        }
        return "redirect:/owner/dashboard";
    }

    @PostMapping("/banner")
    public String uploadBanner(@AuthenticationPrincipal UserPrincipal principal,
                               @RequestParam Long restaurantId,
                               @RequestParam(required = false) MultipartFile imageFile,
                               RedirectAttributes ra) {
        if (imageFile == null || imageFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh banner.");
            return "redirect:/owner/dashboard";
        }
        try {
            String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-banners");
            ownerService.updateRestaurantBanner(principal.getId(), restaurantId, imageUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật banner quán.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng để cập nhật banner.");
        }
        return "redirect:/owner/dashboard";
    }

    @PostMapping("/banner/remove")
    public String removeBanner(@AuthenticationPrincipal UserPrincipal principal,
                               @RequestParam Long restaurantId,
                               RedirectAttributes ra) {
        try {
            ownerService.updateRestaurantBanner(principal.getId(), restaurantId, null);
            ra.addFlashAttribute("successMsg", "Đã xóa banner quán.");
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng để xóa banner.");
        }
        return "redirect:/owner/dashboard";
    }
}
