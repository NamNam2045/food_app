package com.foodrush.restaurant.service;

import com.foodrush.common.dto.PageResponse;
import com.foodrush.restaurant.dto.*;

public interface RestaurantService {
    PageResponse<RestaurantSummaryResponse> getRestaurants(String city, String cuisineType,
            String search, Boolean isOpen, Double lat, Double lng, Double maxDistanceKm,
            int page, int size, String sortBy);
    RestaurantResponse getById(Long id);
    RestaurantResponse getBySlug(String slug);
    RestaurantResponse create(CreateRestaurantRequest request, Long ownerId);
    RestaurantResponse update(Long id, UpdateRestaurantRequest request, Long ownerId);
    void delete(Long id);
}
