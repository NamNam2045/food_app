package com.foodrush.restaurant.repository;

import com.foodrush.restaurant.entity.Restaurant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {

    Optional<Restaurant> findBySlug(String slug);

    boolean existsBySlug(String slug);

    @Query("SELECT r FROM Restaurant r WHERE r.active = true " +
           "AND (:city IS NULL OR LOWER(r.city) = LOWER(:city)) " +
           "AND (:cuisineType IS NULL OR LOWER(r.cuisineType) = LOWER(:cuisineType)) " +
           "AND (:search IS NULL OR LOWER(r.name) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "AND (:isOpen IS NULL OR r.open = :isOpen)")
    Page<Restaurant> findWithFilters(
            @Param("city") String city,
            @Param("cuisineType") String cuisineType,
            @Param("search") String search,
            @Param("isOpen") Boolean isOpen,
            Pageable pageable);

    // Tìm theo khoảng cách (Haversine formula trong JPQL)
    @Query("SELECT r FROM Restaurant r WHERE r.active = true " +
           "AND r.latitude IS NOT NULL AND r.longitude IS NOT NULL " +
           "AND (:isOpen IS NULL OR r.open = :isOpen) " +
           "AND (6371 * acos(cos(radians(:lat)) * cos(radians(r.latitude)) * " +
           "cos(radians(r.longitude) - radians(:lng)) + " +
           "sin(radians(:lat)) * sin(radians(r.latitude)))) <= :maxDistanceKm")
    Page<Restaurant> findNearby(
            @Param("lat") double lat,
            @Param("lng") double lng,
            @Param("maxDistanceKm") double maxDistanceKm,
            @Param("isOpen") Boolean isOpen,
            Pageable pageable);

    Page<Restaurant> findByOwnerIdAndActiveTrue(Long ownerId, Pageable pageable);
}
