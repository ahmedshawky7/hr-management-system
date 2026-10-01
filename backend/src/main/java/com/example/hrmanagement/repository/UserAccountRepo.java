package com.example.hrmanagement.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.hrmanagement.entities.UserAccount;

public interface UserAccountRepo extends JpaRepository<UserAccount, Long> {
    Optional<UserAccount> findByUsername(String username);
    Optional<UserAccount> findByEmployeeId(Long employeeId);

   @Query("""
      SELECT COUNT(u) > 0 FROM UserAccount u
      WHERE u.username = :username AND u.employee.id = :employeeId
      """)
  public boolean isOwner(@Param("username") String username, @Param("employeeId") Long employeeId);
}
 