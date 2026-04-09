package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/reviews")
@RequiredArgsConstructor
public class AdminReviewController {

    private final AdminService adminService;

    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("reviews", adminService.getReviews(page, 20));
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "reviews");
        return "admin/reviews/list";
    }

    @PostMapping("/{id}/toggle-visible")
    public String toggleVisible(@PathVariable Long id,
                                @RequestParam(defaultValue = "0") int page,
                                RedirectAttributes ra) {
        var review = adminService.toggleReviewVisibility(id);
        ra.addFlashAttribute("successMsg",
                "Đánh giá đã được " + (review.isVisible() ? "hiển thị" : "ẩn"));
        return "redirect:/admin/reviews?page=" + page;
    }
}
