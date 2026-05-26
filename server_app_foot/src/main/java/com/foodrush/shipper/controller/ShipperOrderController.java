package com.foodrush.shipper.controller;

import com.foodrush.auth.security.UserPrincipal;
import com.foodrush.common.enums.OrderStatus;
import com.foodrush.common.exceptions.BusinessRuleException;
import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.shipper.service.ShipperService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Slf4j
@Controller
@RequestMapping("/shipper/orders")
@RequiredArgsConstructor
public class ShipperOrderController {

    private final ShipperService shipperService;

    @GetMapping
    public String list(@AuthenticationPrincipal UserPrincipal principal,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        model.addAttribute("orders", shipperService.getMyOrders(principal.getId(), page, 20));
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "orders");
        return "shipper/orders/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id,
                         @AuthenticationPrincipal UserPrincipal principal,
                         Model model) {
        var order = shipperService.getOrderById(id, principal.getId())
                .orElseThrow(() -> new RuntimeException("Order not found"));
        model.addAttribute("order", order);
        model.addAttribute("activePage", "orders");
        return "shipper/orders/detail";
    }

    @PostMapping("/{id}/accept")
    public String acceptOrder(@PathVariable Long id,
                              @AuthenticationPrincipal UserPrincipal principal,
                              RedirectAttributes ra) {
        try {
            shipperService.acceptOrder(id, principal.getId());
            ra.addFlashAttribute("successMsg", "Đã nhận đơn hàng thành công!");
        } catch (BusinessRuleException | ResourceNotFoundException e) {
            log.warn("Shipper {} accept order {} failed: {}", principal.getId(), id, e.getMessage());
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/shipper/dashboard";
        }
        return "redirect:/shipper/orders/" + id;
    }

    @PostMapping("/{id}/status")
    public String updateStatus(@PathVariable Long id,
                               @RequestParam OrderStatus newStatus,
                               @AuthenticationPrincipal UserPrincipal principal,
                               RedirectAttributes ra) {
        try {
            shipperService.updateStatus(id, principal.getId(), newStatus);
            ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái giao hàng.");
        } catch (BusinessRuleException | ResourceNotFoundException e) {
            log.warn("Shipper {} update order {} to {} failed: {}",
                    principal.getId(), id, newStatus, e.getMessage());
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/shipper/orders/" + id;
    }
}
