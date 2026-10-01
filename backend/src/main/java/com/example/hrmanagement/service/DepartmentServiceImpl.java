package com.example.hrmanagement.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.hrmanagement.abstracts.DepartmentService;
import com.example.hrmanagement.dto.DepartmentCreate;
import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.repository.DepartmentRepo;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.shared.CustomResponesException;

@Service
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepo departmentRepo;
    private final EmployeeRepo employeeRepo;  

    public DepartmentServiceImpl(DepartmentRepo departmentRepo, EmployeeRepo employeeRepo) {
        this.departmentRepo = departmentRepo;
        this.employeeRepo = employeeRepo;
    }

    @Override
    public List<Department> getAllDepartments() {
        return departmentRepo.findAll();
    }

    @Override
    public Department createDepartment(DepartmentCreate department) {
        if (departmentRepo.findByName(department.name()).isPresent()) {
            throw CustomResponesException.badRequest(
                "Department with name '" + department.name() + "' already exists");
        }

        Department newDepartment = new Department();
        newDepartment.setName(department.name());
        return departmentRepo.save(newDepartment);
    }

    @Override
    public void deleteDepartment(Long departmentId) {
        if (!departmentRepo.existsById(departmentId)) {
            throw CustomResponesException.resourceNotFound(
                "Department not found with ID: " + departmentId);
        }

        if (employeeRepo.existsByDepartmentId(departmentId)) {
            throw CustomResponesException.badRequest(
                "Cannot delete department: there are employees assigned to it");
        }

        departmentRepo.deleteById(departmentId);
    }

    @Override
    public Department findDepartmentById(Long departmentId) {
        return departmentRepo.findById(departmentId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound(
                        "Department not found with ID: " + departmentId));
    }
}