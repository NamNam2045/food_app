package com.foodrush.user.repository;

import com.foodrush.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByEmailVerificationToken(String token);
    Optional<User> findByPasswordResetToken(String token);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);

    @org.springframework.data.jpa.repository.Query("SELECT u FROM User u WHERE " +
        "LOWER(u.email) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
        "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
        "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :q, '%'))")
    org.springframework.data.domain.Page<User> searchUsers(
        @org.springframework.data.repository.query.Param("q") String q,
        org.springframework.data.domain.Pageable pageable);
}
