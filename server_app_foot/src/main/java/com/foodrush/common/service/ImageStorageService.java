package com.foodrush.common.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class ImageStorageService {

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpg",
            MediaType.IMAGE_JPEG_VALUE,
            MediaType.IMAGE_PNG_VALUE,
            MediaType.IMAGE_GIF_VALUE,
            "image/webp"
    );

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
            ".jpg", ".jpeg", ".png", ".gif", ".webp"
    );

    private final Path uploadRoot;

    public ImageStorageService(@Value("${app.upload-dir:./uploads}") String uploadDir) {
        this.uploadRoot = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    @PostConstruct
    void initialize() {
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException e) {
            throw new IllegalStateException("Không thể khởi tạo thư mục upload", e);
        }
    }

    public String storeImage(MultipartFile file, String folderName) {
        validateFile(file);

        String safeFolder = normalizeFolderName(folderName);
        Path targetDir = uploadRoot.resolve(safeFolder).normalize();
        ensureInsideRoot(targetDir);

        try {
            Files.createDirectories(targetDir);

            String extension = resolveExtension(file.getOriginalFilename(), file.getContentType());
            String filename = UUID.randomUUID().toString().replace("-", "") + extension;
            Path targetFile = targetDir.resolve(filename).normalize();
            ensureInsideRoot(targetFile);

            try (InputStream inputStream = file.getInputStream()) {
                Files.copy(inputStream, targetFile, StandardCopyOption.REPLACE_EXISTING);
            }

            return "/uploads/" + safeFolder + "/" + filename;
        } catch (IOException e) {
            throw new IllegalStateException("Tải ảnh lên thất bại", e);
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh để tải lên.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new IllegalArgumentException("Định dạng ảnh không hợp lệ. Chỉ hỗ trợ JPG, PNG, GIF, WEBP.");
        }
    }

    private String resolveExtension(String originalFilename, String contentType) {
        String extension = extractExtension(originalFilename);
        if (ALLOWED_EXTENSIONS.contains(extension)) {
            return extension;
        }

        if (contentType == null) {
            throw new IllegalArgumentException("Không xác định được định dạng ảnh.");
        }

        String normalizedContentType = contentType.toLowerCase(Locale.ROOT);
        return switch (normalizedContentType) {
            case "image/jpg" -> ".jpg";
            case MediaType.IMAGE_JPEG_VALUE -> ".jpg";
            case MediaType.IMAGE_PNG_VALUE -> ".png";
            case MediaType.IMAGE_GIF_VALUE -> ".gif";
            case "image/webp" -> ".webp";
            default -> throw new IllegalArgumentException("Định dạng ảnh không hợp lệ. Chỉ hỗ trợ JPG, PNG, GIF, WEBP.");
        };
    }

    private String extractExtension(String filename) {
        if (filename == null) {
            return "";
        }
        int idx = filename.lastIndexOf('.');
        if (idx < 0) {
            return "";
        }
        return filename.substring(idx).toLowerCase(Locale.ROOT);
    }

    private String normalizeFolderName(String folderName) {
        String cleaned = folderName == null ? "" : folderName.trim().toLowerCase(Locale.ROOT);
        cleaned = cleaned.replaceAll("[^a-z0-9_-]", "");
        return cleaned.isBlank() ? "common" : cleaned;
    }

    private void ensureInsideRoot(Path path) {
        if (!path.startsWith(uploadRoot)) {
            throw new IllegalArgumentException("Đường dẫn upload không hợp lệ.");
        }
    }
}
