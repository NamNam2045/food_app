package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import com.foodrush.common.enums.OrderStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final AdminService adminService;

    @GetMapping
    public String list(@RequestParam(required = false) OrderStatus status,
                       @RequestParam(required = false) String date,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        model.addAttribute("orders", adminService.getOrders(status, date, page, 20));
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedDate", date);
        model.addAttribute("currentPage", page);
        model.addAttribute("allStatuses", OrderStatus.values());
        model.addAttribute("activePage", "orders");
        return "admin/orders/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        var order = adminService.getOrderById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        model.addAttribute("order", order);
        model.addAttribute("activePage", "orders");
        return "admin/orders/detail";
    }
}
