package com.example.hrmanagement.abstracts;

import java.util.List;

import com.example.hrmanagement.dto.DepartmentCreate;
import com.example.hrmanagement.entities.Department;

public interface DepartmentService {
    List<Department> getAllDepartments();
    Department createDepartment(DepartmentCreate department);
    void deleteDepartment(Long departmentId);
    Department findDepartmentById(Long departmentId);
}
