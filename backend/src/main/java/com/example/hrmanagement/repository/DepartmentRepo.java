package com.example.hrmanagement.repository;


import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.hrmanagement.entities.Department;

public interface DepartmentRepo extends JpaRepository<Department,Long> {
    Optional<Department> findByName(String name);    
}
