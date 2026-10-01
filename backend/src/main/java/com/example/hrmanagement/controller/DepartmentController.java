package com.example.hrmanagement.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.hrmanagement.abstracts.DepartmentService;
import com.example.hrmanagement.dto.DepartmentCreate;
import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.shared.GlobalRespones;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/departments")
public class DepartmentController {

    private final DepartmentService departmentService;

    public DepartmentController(DepartmentService departmentService) {
        this.departmentService = departmentService;
    }

    @GetMapping
    public ResponseEntity<GlobalRespones<List<Department>>> getAllDepartments() {
        return new ResponseEntity<>(new GlobalRespones<>(departmentService.getAllDepartments()), HttpStatus.OK);
    }

    @PostMapping
    public ResponseEntity<GlobalRespones<Department>> createDepartment(@RequestBody @Valid DepartmentCreate department) {
        Department newDepartment = departmentService.createDepartment(department);
        return new ResponseEntity<>(new GlobalRespones<>(newDepartment), HttpStatus.CREATED);
    }

    @GetMapping("/{departmentId}")
    public ResponseEntity<GlobalRespones<Department>> getOneDepartment(@PathVariable Long departmentId) {
        Department department = departmentService.findDepartmentById(departmentId);
        return new ResponseEntity<>(new GlobalRespones<>(department), HttpStatus.OK);
    }

    @DeleteMapping("/{departmentId}")
    public ResponseEntity<Void> deleteDepartment(@PathVariable Long departmentId) {
        departmentService.deleteDepartment(departmentId);
        return ResponseEntity.noContent().build();
    }

}
