package com.foodrush.admin.controller;

import com.foodrush.admin.service.AdminService;
import com.foodrush.order.entity.PromoCode;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/admin/promo-codes")
@RequiredArgsConstructor
public class AdminPromoController {

    private final AdminService adminService;

    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("promoCodes", adminService.getPromoCodes(page, 20));
        model.addAttribute("currentPage", page);
        model.addAttribute("activePage", "promo");
        model.addAttribute("newPromo", new PromoForm());
        return "admin/promo/list";
    }

    @PostMapping("/create")
    public String create(@ModelAttribute PromoForm form, RedirectAttributes ra) {
        try {
            PromoCode promo = PromoCode.builder()
                    .code(form.getCode().toUpperCase().trim())
                    .discountType(form.getDiscountType())
                    .discountValue(form.getDiscountValue())
                    .minOrderAmount(form.getMinOrderAmount())
                    .maxDiscountAmount(form.getMaxDiscountAmount())
                    .startDate(form.getStartDate())
                    .endDate(form.getEndDate())
                    .usageLimit(form.getUsageLimit())
                    .active(true)
                    .build();
            adminService.savePromoCode(promo);
            ra.addFlashAttribute("successMsg", "Tạo mã giảm giá \"" + promo.getCode() + "\" thành công");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
        return "redirect:/admin/promo-codes";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        adminService.deletePromoCode(id);
        ra.addFlashAttribute("successMsg", "Đã xóa mã giảm giá");
        return "redirect:/admin/promo-codes";
    }

    @PostMapping("/{id}/toggle")
    public String toggle(@PathVariable Long id, RedirectAttributes ra) {
        adminService.togglePromoCode(id);
        ra.addFlashAttribute("successMsg", "Đã cập nhật trạng thái mã giảm giá");
        return "redirect:/admin/promo-codes";
    }

    /** Form DTO for promo creation (avoid exposing entity directly) */
    public static class PromoForm {
        private String code;
        private String discountType = "PERCENTAGE";
        private BigDecimal discountValue;
        private BigDecimal minOrderAmount;
        private BigDecimal maxDiscountAmount;
        @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime startDate;
        @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime endDate;
        private Integer usageLimit = 9999;

        public String getCode() { return code; }
        public void setCode(String code) { this.code = code; }
        public String getDiscountType() { return discountType; }
        public void setDiscountType(String discountType) { this.discountType = discountType; }
        public BigDecimal getDiscountValue() { return discountValue; }
        public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }
        public BigDecimal getMinOrderAmount() { return minOrderAmount; }
        public void setMinOrderAmount(BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }
        public BigDecimal getMaxDiscountAmount() { return maxDiscountAmount; }
        public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }
        public LocalDateTime getStartDate() { return startDate; }
        public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }
        public LocalDateTime getEndDate() { return endDate; }
        public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }
        public Integer getUsageLimit() { return usageLimit; }
        public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }
    }
}
