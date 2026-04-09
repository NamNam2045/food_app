package com.foodrush.menu.repository;

import com.foodrush.menu.entity.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, Long> {
    List<MenuItem> findByCategoryIdOrderByDisplayOrderAsc(Long categoryId);
    List<MenuItem> findByRestaurantIdAndAvailableTrueAndFeaturedTrue(Long restaurantId);
}
