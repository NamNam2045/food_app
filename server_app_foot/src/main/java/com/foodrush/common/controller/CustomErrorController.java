package com.foodrush.common.controller;

import com.foodrush.common.dto.ApiResponse;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Slf4j
@Controller
public class CustomErrorController implements ErrorController {

    private static final String ERROR_PATH = "/error";

    @RequestMapping(ERROR_PATH)
    public Object handleError(HttpServletRequest request, Model model) {
        int status = resolveStatus(request);
        String originalUri = resolveOriginalUri(request);
        String message = resolveMessage(request);
        Throwable exception = (Throwable) request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);

        log.warn("Error page hit: status={}, uri={}, message={}, ex={}",
                status, originalUri, message, exception != null ? exception.toString() : "n/a");

        if (wantsJson(request, originalUri)) {
            return jsonResponse(status, message);
        }

        model.addAttribute("status", status);
        model.addAttribute("path", originalUri);
        model.addAttribute("message", friendlyMessage(status, message));
        model.addAttribute("title", titleForStatus(status));
        model.addAttribute("icon", iconForStatus(status));
        model.addAttribute("timestamp", new java.util.Date());
        model.addAttribute("loginPath", resolveLoginPath(originalUri));

        return "error/error";
    }

    private int resolveStatus(HttpServletRequest request) {
        Object code = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        if (code instanceof Integer i) {
            return i;
        }
        return HttpStatus.INTERNAL_SERVER_ERROR.value();
    }

    private String resolveOriginalUri(HttpServletRequest request) {
        Object uri = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        return uri != null ? uri.toString() : request.getRequestURI();
    }

    private String resolveMessage(HttpServletRequest request) {
        Object msg = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        return msg != null ? msg.toString() : "";
    }

    private boolean wantsJson(HttpServletRequest request, String originalUri) {
        if (originalUri != null && (originalUri.startsWith("/api/") || originalUri.startsWith("/ws/"))) {
            return true;
        }
        String accept = request.getHeader("Accept");
        return accept != null && accept.contains(MediaType.APPLICATION_JSON_VALUE);
    }

    private ResponseEntity<ApiResponse<Void>> jsonResponse(int status, String message) {
        HttpStatus httpStatus = HttpStatus.resolve(status);
        if (httpStatus == null) {
            httpStatus = HttpStatus.INTERNAL_SERVER_ERROR;
        }
        String code = switch (httpStatus) {
            case NOT_FOUND -> "NOT_FOUND";
            case FORBIDDEN -> "FORBIDDEN";
            case UNAUTHORIZED -> "UNAUTHORIZED";
            case BAD_REQUEST -> "BAD_REQUEST";
            default -> "INTERNAL_ERROR";
        };
        String safeMessage = (message == null || message.isBlank())
                ? httpStatus.getReasonPhrase()
                : message;
        return ResponseEntity.status(httpStatus).body(ApiResponse.error(code, safeMessage));
    }

    private String titleForStatus(int status) {
        return switch (status) {
            case 400 -> "Yêu cầu không hợp lệ";
            case 401 -> "Chưa đăng nhập";
            case 403 -> "Truy cập bị từ chối";
            case 404 -> "Không tìm thấy trang";
            case 405 -> "Phương thức không hỗ trợ";
            case 500 -> "Lỗi máy chủ";
            default -> "Đã xảy ra lỗi";
        };
    }

    private String iconForStatus(int status) {
        return switch (status) {
            case 401, 403 -> "bi bi-shield-lock-fill";
            case 404 -> "bi bi-compass";
            case 500 -> "bi bi-bug-fill";
            default -> "bi bi-exclamation-octagon-fill";
        };
    }

    private String friendlyMessage(int status, String fallback) {
        return switch (status) {
            case 401 -> "Bạn cần đăng nhập để tiếp tục.";
            case 403 -> "Bạn không có quyền truy cập trang này.";
            case 404 -> "Trang bạn tìm kiếm không tồn tại.";
            case 500 -> "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.";
            default -> (fallback == null || fallback.isBlank())
                    ? "Đã xảy ra lỗi không xác định."
                    : fallback;
        };
    }

    private String resolveLoginPath(String uri) {
        if (uri == null) return "/admin/login";
        if (uri.startsWith("/owner")) return "/owner/login";
        if (uri.startsWith("/shipper")) return "/shipper/login";
        return "/admin/login";
    }
}
