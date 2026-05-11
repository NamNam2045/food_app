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

import java.math.BigDecimal;

@Controller
@RequestMapping("/owner/menu")
@RequiredArgsConstructor
public class OwnerMenuController {

    private final OwnerService ownerService;
    private final ImageStorageService imageStorageService;

    private Restaurant getRestaurantOrThrow(Long ownerId) {
        return ownerService.getRestaurantByOwner(ownerId)
                .orElseThrow(() -> new RuntimeException("No restaurant found for this owner"));
    }

    // ─── LIST ─────────────────────────────────────────────────────────────────

    @GetMapping
    public String list(@AuthenticationPrincipal UserPrincipal principal, Model model) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        var categories = ownerService.getCategories(restaurant.getId());

        model.addAttribute("restaurant", restaurant);
        model.addAttribute("categories", categories);
        var itemMap = new java.util.LinkedHashMap<Long, java.util.List<com.foodrush.menu.entity.MenuItem>>();
        categories.forEach(cat -> itemMap.put(cat.getId(), ownerService.getItemsByCategory(cat.getId())));
        model.addAttribute("itemMap", itemMap);
        model.addAttribute("activePage", "menu");
        return "owner/menu/list";
    }

    // ─── CATEGORY CRUD ────────────────────────────────────────────────────────

    @PostMapping("/categories/create")
    public String createCategory(@AuthenticationPrincipal UserPrincipal principal,
                                 @RequestParam String name,
                                 @RequestParam(required = false) String description,
                                 @RequestParam(defaultValue = "0") int displayOrder,
                                 RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.createCategory(restaurant.getId(), name, description, displayOrder);
        ra.addFlashAttribute("successMsg", "Đã thêm danh mục \"" + name + "\"");
        return "redirect:/owner/menu";
    }

    @PostMapping("/categories/{catId}/update")
    public String updateCategory(@PathVariable Long catId,
                                 @AuthenticationPrincipal UserPrincipal principal,
                                 @RequestParam String name,
                                 @RequestParam(required = false) String description,
                                 @RequestParam(defaultValue = "0") int displayOrder,
                                 RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.updateCategory(catId, restaurant.getId(), name, description, displayOrder);
        ra.addFlashAttribute("successMsg", "Đã cập nhật danh mục.");
        return "redirect:/owner/menu";
    }

    @PostMapping("/categories/{catId}/delete")
    public String deleteCategory(@PathVariable Long catId,
                                 @AuthenticationPrincipal UserPrincipal principal,
                                 RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.deleteCategory(catId, restaurant.getId());
        ra.addFlashAttribute("successMsg", "Đã ẩn danh mục.");
        return "redirect:/owner/menu";
    }

    // ─── ITEM CRUD ────────────────────────────────────────────────────────────

    @PostMapping("/items/create")
    public String createItem(@AuthenticationPrincipal UserPrincipal principal,
                             @RequestParam Long categoryId,
                             @RequestParam String name,
                             @RequestParam(required = false) String description,
                             @RequestParam BigDecimal price,
                             @RequestParam(required = false) MultipartFile imageFile,
                             @RequestParam(defaultValue = "false") boolean featured,
                             @RequestParam(required = false) Integer calories,
                             @RequestParam(required = false) Integer preparationTimeMinutes,
                             @RequestParam(defaultValue = "0") int displayOrder,
                             RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        String imageUrl = null;
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                imageUrl = imageStorageService.storeImage(imageFile, "menu-items");
            } catch (IllegalArgumentException | IllegalStateException ex) {
                ra.addFlashAttribute("errorMsg", ex.getMessage());
                return "redirect:/owner/menu";
            }
        }

        ownerService.createMenuItem(restaurant.getId(), categoryId, name, description, price, imageUrl,
                featured, calories, preparationTimeMinutes, displayOrder);
        ra.addFlashAttribute("successMsg", "Đã thêm món \"" + name + "\"");
        return "redirect:/owner/menu";
    }

    @PostMapping("/items/{itemId}/update")
    public String updateItem(@PathVariable Long itemId,
                             @AuthenticationPrincipal UserPrincipal principal,
                             @RequestParam Long categoryId,
                             @RequestParam String name,
                             @RequestParam(required = false) String description,
                             @RequestParam BigDecimal price,
                             @RequestParam(required = false) MultipartFile imageFile,
                             @RequestParam(defaultValue = "false") boolean removeImage,
                             @RequestParam(defaultValue = "false") boolean available,
                             @RequestParam(defaultValue = "false") boolean featured,
                             @RequestParam(required = false) Integer calories,
                             @RequestParam(required = false) Integer preparationTimeMinutes,
                             @RequestParam(defaultValue = "0") int displayOrder,
                             RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        var currentItemOpt = ownerService.getMenuItemById(itemId, restaurant.getId());
        if (currentItemOpt.isEmpty()) {
            ra.addFlashAttribute("errorMsg", "Không tìm thấy món ăn để cập nhật.");
            return "redirect:/owner/menu";
        }

        String imageUrl = currentItemOpt.get().getImageUrl();
        if (removeImage) {
            imageUrl = null;
        }
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                imageUrl = imageStorageService.storeImage(imageFile, "menu-items");
            } catch (IllegalArgumentException | IllegalStateException ex) {
                ra.addFlashAttribute("errorMsg", ex.getMessage());
                return "redirect:/owner/menu";
            }
        }

        ownerService.updateMenuItem(itemId, restaurant.getId(), categoryId, name, description,
                price, imageUrl, available, featured, calories, preparationTimeMinutes, displayOrder);
        ra.addFlashAttribute("successMsg", "Đã cập nhật món \"" + name + "\"");
        return "redirect:/owner/menu";
    }

    @PostMapping("/items/{itemId}/delete")
    public String deleteItem(@PathVariable Long itemId,
                             @AuthenticationPrincipal UserPrincipal principal,
                             RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.deleteMenuItem(itemId, restaurant.getId());
        ra.addFlashAttribute("successMsg", "Đã xóa món ăn.");
        return "redirect:/owner/menu";
    }

    @PostMapping("/items/{itemId}/toggle")
    public String toggleItem(@PathVariable Long itemId,
                             @AuthenticationPrincipal UserPrincipal principal,
                             RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.toggleItemAvailable(itemId, restaurant.getId());
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái món ăn.");
        return "redirect:/owner/menu";
    }
}
