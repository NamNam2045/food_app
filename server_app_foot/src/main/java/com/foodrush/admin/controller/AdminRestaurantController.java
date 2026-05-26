package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.common.service.ImageStorageService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Slf4j
@Controller
@RequestMapping("/admin/restaurants")
@RequiredArgsConstructor
public class AdminRestaurantController {

    private final AdminService adminService;
    private final ImageStorageService imageStorageService;

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

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("owners", adminService.getAvailableOwners());
        model.addAttribute("activePage", "restaurants");
        return "admin/restaurants/new";
    }

    @PostMapping("/create")
    public String create(@RequestParam Long ownerId,
                         @RequestParam String name,
                         @RequestParam String cuisineType,
                         @RequestParam String streetAddress,
                         @RequestParam String city,
                         @RequestParam(required = false) String description,
                         @RequestParam(required = false) String phone,
                         @RequestParam(required = false) String email,
                         @RequestParam(required = false) BigDecimal minOrderAmount,
                         @RequestParam(required = false) BigDecimal deliveryFee,
                         @RequestParam(required = false) Integer estimatedDeliveryMinutes,
                         @RequestParam(required = false) MultipartFile logoFile,
                         @RequestParam(required = false) MultipartFile bannerFile,
                         RedirectAttributes ra) {
        try {
            Restaurant created = adminService.createRestaurant(ownerId, name, cuisineType,
                    streetAddress, city, description, phone, email,
                    minOrderAmount, deliveryFee, estimatedDeliveryMinutes);

            if (logoFile != null && !logoFile.isEmpty()) {
                String url = imageStorageService.storeImage(logoFile, "restaurant-logos");
                adminService.updateRestaurantLogo(created.getId(), url);
            }
            if (bannerFile != null && !bannerFile.isEmpty()) {
                String url = imageStorageService.storeImage(bannerFile, "restaurant-banners");
                adminService.updateRestaurantBanner(created.getId(), url);
            }
            ra.addFlashAttribute("successMsg", "Đã tạo nhà hàng \"" + created.getName() + "\"");
            return "redirect:/admin/restaurants/" + created.getId();
        } catch (BusinessRuleException | ResourceNotFoundException |
                 IllegalArgumentException | IllegalStateException ex) {
            log.warn("Create restaurant failed: {}", ex.getMessage());
            ra.addFlashAttribute("errorMsg", ex.getMessage());
            return "redirect:/admin/restaurants/new";
        }
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

    @PostMapping("/{id}/logo")
    public String uploadLogo(@PathVariable Long id,
                             @RequestParam(required = false) MultipartFile imageFile,
                             RedirectAttributes ra) {
        if (imageFile == null || imageFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh logo.");
            return "redirect:/admin/restaurants/" + id;
        }
        try {
            String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-logos");
            adminService.updateRestaurantLogo(id, imageUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật logo nhà hàng.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng cần cập nhật logo.");
        }
        return "redirect:/admin/restaurants/" + id;
    }

    @PostMapping("/{id}/logo/remove")
    public String removeLogo(@PathVariable Long id, RedirectAttributes ra) {
        try {
            adminService.updateRestaurantLogo(id, null);
            ra.addFlashAttribute("successMsg", "Đã xóa logo nhà hàng.");
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng cần xóa logo.");
        }
        return "redirect:/admin/restaurants/" + id;
    }

    @PostMapping("/{id}/banner")
    public String uploadBanner(@PathVariable Long id,
                               @RequestParam(required = false) MultipartFile imageFile,
                               RedirectAttributes ra) {
        if (imageFile == null || imageFile.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Vui lòng chọn ảnh banner.");
            return "redirect:/admin/restaurants/" + id;
        }
        try {
            String imageUrl = imageStorageService.storeImage(imageFile, "restaurant-banners");
            adminService.updateRestaurantBanner(id, imageUrl);
            ra.addFlashAttribute("successMsg", "Đã cập nhật banner nhà hàng.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            ra.addFlashAttribute("errorMsg", ex.getMessage());
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng cần cập nhật banner.");
        }
        return "redirect:/admin/restaurants/" + id;
    }

    @PostMapping("/{id}/banner/remove")
    public String removeBanner(@PathVariable Long id, RedirectAttributes ra) {
        try {
            adminService.updateRestaurantBanner(id, null);
            ra.addFlashAttribute("successMsg", "Đã xóa banner nhà hàng.");
        } catch (RuntimeException ex) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy nhà hàng cần xóa banner.");
        }
        return "redirect:/admin/restaurants/" + id;
    }
}
