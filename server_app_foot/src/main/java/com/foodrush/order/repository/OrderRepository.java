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

    // --- Owner portal ---
    @Query(value = "SELECT DISTINCT o FROM Order o JOIN FETCH o.user " +
                   "WHERE o.restaurant.id = :restaurantId " +
                   "AND (:status IS NULL OR o.status = :status) " +
                   "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
                   "AND (:endDate IS NULL OR o.createdAt < :endDate)",
           countQuery = "SELECT COUNT(o) FROM Order o WHERE o.restaurant.id = :restaurantId " +
                   "AND (:status IS NULL OR o.status = :status) " +
                   "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
                   "AND (:endDate IS NULL OR o.createdAt < :endDate)")
    Page<Order> findByRestaurantForOwner(
            @Param("restaurantId") Long restaurantId,
            @Param("status") OrderStatus status,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);

    @Query("SELECT o FROM Order o JOIN FETCH o.user WHERE o.restaurant.id = :restaurantId " +
           "ORDER BY o.createdAt DESC")
    List<Order> findRecentByRestaurant(@Param("restaurantId") Long restaurantId, Pageable pageable);

    long countByRestaurantIdAndStatus(Long restaurantId, OrderStatus status);

    long countByRestaurantIdAndCreatedAtAfter(Long restaurantId, LocalDateTime after);

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.restaurant.id = :rid AND o.status = 'DELIVERED'")
    java.math.BigDecimal sumDeliveredByRestaurant(@Param("rid") Long restaurantId);

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.restaurant.id = :rid AND o.status = 'DELIVERED' AND o.createdAt >= :after")
    java.math.BigDecimal sumDeliveredByRestaurantAfter(@Param("rid") Long restaurantId, @Param("after") LocalDateTime after);

    // --- Shipper portal ---
    @Query(value = "SELECT DISTINCT o FROM Order o JOIN FETCH o.user JOIN FETCH o.restaurant " +
                   "WHERE o.deliveryAgent.id = :agentId",
           countQuery = "SELECT COUNT(o) FROM Order o WHERE o.deliveryAgent.id = :agentId")
    Page<Order> findByDeliveryAgentForShipper(
            @Param("agentId") Long agentId, Pageable pageable);

    @Query("SELECT o FROM Order o JOIN FETCH o.user JOIN FETCH o.restaurant " +
           "WHERE o.deliveryAgent.id = :agentId AND o.status IN ('PICKED_UP', 'ON_THE_WAY') " +
           "ORDER BY o.createdAt DESC")
    List<Order> findActiveForShipper(@Param("agentId") Long agentId);

    @Query("SELECT o FROM Order o JOIN FETCH o.user JOIN FETCH o.restaurant " +
           "WHERE o.status = 'READY_FOR_PICKUP' AND o.deliveryAgent IS NULL " +
           "ORDER BY o.createdAt ASC")
    List<Order> findAvailableForPickup();

    long countByDeliveryAgentIdAndStatus(Long agentId, OrderStatus status);

    @Query("SELECT o FROM Order o JOIN FETCH o.user JOIN FETCH o.restaurant LEFT JOIN FETCH o.items WHERE o.id = :id")
    java.util.Optional<Order> findByIdWithDetails(@Param("id") Long id);
}
