package com.example.hrmanagement.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.hrmanagement.entities.PasswordResetToken;

import java.util.Optional;

public interface PasswordRestRepo extends JpaRepository<PasswordResetToken, Long> {
  Optional<PasswordResetToken> findOneByToken(String token);
  Optional<PasswordResetToken> findByUserId(Long userId);
}