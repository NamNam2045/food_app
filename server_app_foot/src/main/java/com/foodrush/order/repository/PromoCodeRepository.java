package com.foodrush.order.repository;

import com.foodrush.order.entity.PromoCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PromoCodeRepository extends JpaRepository<PromoCode, Long> {
    Optional<PromoCode> findByCodeAndActiveTrue(String code);

    @Modifying
    @Query("UPDATE PromoCode p SET p.usedCount = p.usedCount + 1 WHERE p.id = :id")
    void incrementUsedCount(Long id);
}
