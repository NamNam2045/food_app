package com.foodrush.owner.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.owner.service.OwnerService;
import com.foodrush.restaurant.entity.Restaurant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/owner/orders")
@RequiredArgsConstructor
public class OwnerOrderController {

    private final OwnerService ownerService;

    private Restaurant getRestaurantOrThrow(Long ownerId) {
        return ownerService.getRestaurantByOwner(ownerId)
                .orElseThrow(() -> new RuntimeException("No restaurant found for this owner"));
    }

    @GetMapping
    public String list(@AuthenticationPrincipal UserPrincipal principal,
                       @RequestParam(required = false) OrderStatus status,
                       @RequestParam(required = false) String date,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("orders", ownerService.getOrders(restaurant.getId(), status, date, page, 20));
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedDate", date);
        model.addAttribute("currentPage", page);
        model.addAttribute("allStatuses", OrderStatus.values());
        model.addAttribute("activePage", "orders");
        return "owner/orders/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id,
                         @AuthenticationPrincipal UserPrincipal principal,
                         Model model) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        var order = ownerService.getOrderById(id, restaurant.getId())
                .orElseThrow(() -> new RuntimeException("Order not found"));
        model.addAttribute("restaurant", restaurant);
        model.addAttribute("order", order);
        model.addAttribute("activePage", "orders");
        return "owner/orders/detail";
    }

    @PostMapping("/{id}/status")
    public String updateStatus(@PathVariable Long id,
                               @RequestParam OrderStatus newStatus,
                               @AuthenticationPrincipal UserPrincipal principal,
                               RedirectAttributes ra) {
        Restaurant restaurant = getRestaurantOrThrow(principal.getId());
        ownerService.updateOrderStatus(id, restaurant.getId(), newStatus);
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái đơn hàng.");
        return "redirect:/owner/orders/" + id;
    }
}
