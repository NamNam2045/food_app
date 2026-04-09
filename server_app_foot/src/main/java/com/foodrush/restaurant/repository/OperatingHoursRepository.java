package com.foodrush.restaurant.repository;

import com.foodrush.restaurant.entity.OperatingHours;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OperatingHoursRepository extends JpaRepository<OperatingHours, Long> {
    List<OperatingHours> findByRestaurantId(Long restaurantId);
    void deleteByRestaurantId(Long restaurantId);
}
