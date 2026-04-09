package com.foodrush.order.repository;

import com.foodrush.common.enums.OrderStatus;
import com.foodrush.order.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long>, JpaSpecificationExecutor<Order> {
    Page<Order> findByUserId(Long userId, Pageable pageable);
    Page<Order> findByUserIdAndStatus(Long userId, OrderStatus status, Pageable pageable);
    Page<Order> findByRestaurantId(Long restaurantId, Pageable pageable);
    Page<Order> findByRestaurantIdAndStatus(Long restaurantId, OrderStatus status, Pageable pageable);

    @Query("SELECT o FROM Order o WHERE o.restaurant.id = :restaurantId " +
           "AND (:status IS NULL OR o.status = :status) " +
           "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
           "AND (:endDate IS NULL OR o.createdAt < :endDate)")
    Page<Order> findByRestaurantWithFilters(
            @Param("restaurantId") Long restaurantId,
            @Param("status") OrderStatus status,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);

    @Query("SELECT COUNT(o) FROM Order o WHERE DATE(o.createdAt) = :date")
    long countByCreatedAtDate(LocalDate date);

    long countByStatus(OrderStatus status);

    long countByCreatedAtAfter(LocalDateTime after);

    @Query("SELECT o FROM Order o WHERE " +
           "(:status IS NULL OR o.status = :status) " +
           "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
           "AND (:endDate IS NULL OR o.createdAt < :endDate)")
    Page<Order> findAllWithFilters(
            @Param("status") OrderStatus status,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);

    @EntityGraph(attributePaths = {"user", "restaurant"})
    @Override
    Page<Order> findAll(Specification<Order> spec, Pageable pageable);

    @Query("SELECT o FROM Order o JOIN FETCH o.user JOIN FETCH o.restaurant ORDER BY o.createdAt DESC")
    List<Order> findRecentForAdmin(Pageable pageable);
}
