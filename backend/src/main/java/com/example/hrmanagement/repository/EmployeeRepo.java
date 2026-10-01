package com.example.hrmanagement.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.hrmanagement.entities.Employee;

public interface EmployeeRepo extends JpaRepository<Employee, Long> {
   List<Employee> findByDepartmentId(Long departmentId);

   Optional<Employee> findByAccountCreationToken(String token);

   boolean existsByDepartmentId(Long departmentId);

   @Query("""
         SELECT COUNT(e) > 0 FROM Employee e
         WHERE e.manager.id = :managerId AND e.id = :targetId
         """)
   boolean isDirectReport(@Param("managerId") Long managerId, @Param("targetId") Long targetId);

   boolean existsByManagerId(Long managerId);
}
