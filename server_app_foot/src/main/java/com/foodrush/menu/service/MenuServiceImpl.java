package com.foodrush.menu.service;

import com.foodrush.common.exceptions.ResourceNotFoundException;
import com.foodrush.menu.dto.*;
import com.foodrush.menu.entity.MenuCategory;
import com.foodrush.menu.entity.MenuItem;
import com.foodrush.menu.repository.MenuCategoryRepository;
import com.foodrush.menu.repository.MenuItemRepository;
import com.foodrush.restaurant.entity.Restaurant;
import com.foodrush.restaurant.repository.RestaurantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class MenuServiceImpl implements MenuService {

    private final MenuCategoryRepository categoryRepository;
    private final MenuItemRepository itemRepository;
    private final RestaurantRepository restaurantRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryWithItemsResponse> getMenuByRestaurant(Long restaurantId) {
        return categoryRepository.findByRestaurantIdAndActiveTrueOrderByDisplayOrderAsc(restaurantId)
                .stream().map(cat -> CategoryWithItemsResponse.builder()
                        .id(cat.getId()).name(cat.getName()).description(cat.getDescription())
                        .displayOrder(cat.getDisplayOrder())
                        .items(cat.getItems().stream()
                                .filter(MenuItem::isAvailable)
                                .map(this::toItemResponse)
                                .collect(Collectors.toList()))
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public MenuItemResponse getItemById(Long restaurantId, Long itemId) {
        MenuItem item = itemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Món ăn không tồn tại"));
        return toItemResponse(item);
    }

    @Override
    public CategoryWithItemsResponse createCategory(Long restaurantId, CreateCategoryRequest request) {
        Restaurant restaurant = findRestaurant(restaurantId);
        MenuCategory category = MenuCategory.builder()
                .restaurant(restaurant).name(request.getName())
                .description(request.getDescription())
                .displayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : 0)
                .build();
        category = categoryRepository.save(category);
        return CategoryWithItemsResponse.builder()
                .id(category.getId()).name(category.getName())
                .description(category.getDescription()).displayOrder(category.getDisplayOrder())
                .items(List.of()).build();
    }

    @Override
    public CategoryWithItemsResponse updateCategory(Long restaurantId, Long categoryId, UpdateCategoryRequest request) {
        MenuCategory category = categoryRepository.findById(categoryId)
                .filter(c -> c.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Danh mục không tồn tại"));

        if (StringUtils.hasText(request.getName())) category.setName(request.getName());
        if (StringUtils.hasText(request.getDescription())) category.setDescription(request.getDescription());
        if (request.getDisplayOrder() != null) category.setDisplayOrder(request.getDisplayOrder());
        if (request.getActive() != null) category.setActive(request.getActive());

        category = categoryRepository.save(category);
        List<MenuItemResponse> items = category.getItems().stream()
                .filter(MenuItem::isAvailable)
                .map(this::toItemResponse)
                .collect(Collectors.toList());
        return CategoryWithItemsResponse.builder()
                .id(category.getId()).name(category.getName())
                .description(category.getDescription()).displayOrder(category.getDisplayOrder())
                .items(items).build();
    }

    @Override
    public void deleteCategory(Long restaurantId, Long categoryId) {
        MenuCategory category = categoryRepository.findById(categoryId)
                .filter(c -> c.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Danh mục không tồn tại"));
        // Soft delete: ẩn danh mục và tất cả items bên trong
        category.setActive(false);
        category.getItems().forEach(item -> item.setAvailable(false));
        categoryRepository.save(category);
    }

    @Override
    public MenuItemResponse createItem(Long restaurantId, CreateMenuItemRequest request) {
        Restaurant restaurant = findRestaurant(restaurantId);
        MenuCategory category = categoryRepository.findById(request.getCategoryId())
                .filter(c -> c.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Danh mục không tồn tại"));

        MenuItem item = MenuItem.builder()
                .category(category).restaurant(restaurant).name(request.getName())
                .description(request.getDescription()).price(request.getPrice())
                .imageUrl(request.getImageUrl()).available(request.isAvailable())
                .featured(request.isFeatured()).calories(request.getCalories())
                .preparationTimeMinutes(request.getPreparationTimeMinutes() != null ? request.getPreparationTimeMinutes() : 15)
                .displayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : 0)
                .build();
        return toItemResponse(itemRepository.save(item));
    }

    @Override
    public MenuItemResponse updateItem(Long restaurantId, Long itemId, UpdateMenuItemRequest request) {
        MenuItem item = itemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Món ăn không tồn tại"));

        if (StringUtils.hasText(request.getName())) item.setName(request.getName());
        if (StringUtils.hasText(request.getDescription())) item.setDescription(request.getDescription());
        if (request.getPrice() != null) item.setPrice(request.getPrice());
        if (StringUtils.hasText(request.getImageUrl())) item.setImageUrl(request.getImageUrl());
        if (request.getAvailable() != null) item.setAvailable(request.getAvailable());
        if (request.getFeatured() != null) item.setFeatured(request.getFeatured());
        if (request.getCalories() != null) item.setCalories(request.getCalories());
        if (request.getPreparationTimeMinutes() != null) item.setPreparationTimeMinutes(request.getPreparationTimeMinutes());
        if (request.getDisplayOrder() != null) item.setDisplayOrder(request.getDisplayOrder());
        return toItemResponse(itemRepository.save(item));
    }

    @Override
    public MenuItemResponse updateItemImage(Long restaurantId, Long itemId, String imageUrl) {
        MenuItem item = itemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Món ăn không tồn tại"));
        item.setImageUrl(imageUrl);
        return toItemResponse(itemRepository.save(item));
    }

    @Override
    public void deleteItem(Long restaurantId, Long itemId) {
        MenuItem item = itemRepository.findById(itemId)
                .filter(i -> i.getRestaurant().getId().equals(restaurantId))
                .orElseThrow(() -> new ResourceNotFoundException("Món ăn không tồn tại"));
        item.setAvailable(false);
        itemRepository.save(item);
    }

    private Restaurant findRestaurant(Long id) {
        return restaurantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Nhà hàng không tồn tại"));
    }

    private MenuItemResponse toItemResponse(MenuItem i) {
        return MenuItemResponse.builder()
                .id(i.getId()).categoryId(i.getCategory().getId()).name(i.getName())
                .description(i.getDescription()).price(i.getPrice()).imageUrl(i.getImageUrl())
                .available(i.isAvailable()).featured(i.isFeatured()).calories(i.getCalories())
                .preparationTimeMinutes(i.getPreparationTimeMinutes()).displayOrder(i.getDisplayOrder())
                .build();
    }
}
