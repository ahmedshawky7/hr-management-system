package com.example.hrmanagement.controller;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.hrmanagement.abstracts.EmployeeService;
import com.example.hrmanagement.dto.EmployeeCreate;
import com.example.hrmanagement.dto.EmployeeUpdate;
import com.example.hrmanagement.dto.PaginatedResponse;
import com.example.hrmanagement.dto.RoleUpdateRequest;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.shared.GlobalRespones;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/employees")
public class EmployeeController {

    private final EmployeeService employeeService;

    
    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping
    public ResponseEntity<GlobalRespones<PaginatedResponse<Employee>>> getAllEmployees(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "3") int size, HttpServletRequest request) {

        int currentPage = page - 1;
        Page<Employee> employees = employeeService.getAllEmployees(currentPage, size);
        String baseUrl = request.getRequestURL().toString();
        String nextUrl = employees.hasNext() ? baseUrl + "?page=" + (page + 1) + "&size=" + size : null;
        String previousUrl = employees.hasPrevious() ? baseUrl + "?page=" + (page - 1) + "&size=" + size : null;

        var paginatedResponse = new PaginatedResponse<Employee>(
                employees.getContent(),
                employees.getNumber(),
                employees.getTotalPages(),
                employees.getTotalElements(),
                employees.hasNext(),
                employees.hasPrevious(),
                nextUrl,
                previousUrl);

        return new ResponseEntity<>(new GlobalRespones<>(paginatedResponse), HttpStatus.OK);
    }

    @GetMapping("/{employeeId}")
    public ResponseEntity<GlobalRespones<Employee>> getOneEmployee(@PathVariable Long employeeId) {
        Employee employee = employeeService.findById(employeeId);
        return new ResponseEntity<>(new GlobalRespones<>(employee), HttpStatus.OK);
    }

    @DeleteMapping("/{employeeId}")
    public ResponseEntity<Void> deleteEmployee(@PathVariable Long employeeId) {
        employeeService.deleteEmployee(employeeId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{employeeId}")
    public ResponseEntity<GlobalRespones<Employee>> updateEmployee(@PathVariable Long employeeId,
            @RequestBody @Valid EmployeeUpdate updatedEmployee) {
        Employee updateEmployee = employeeService.updateEmployee(employeeId, updatedEmployee);
        return new ResponseEntity<>(new GlobalRespones<>(updateEmployee), HttpStatus.OK);
    }

    @PutMapping("/{employeeId}/role")
    public ResponseEntity<Void> updateRole(@PathVariable Long employeeId,
            @RequestBody @Valid RoleUpdateRequest request) {
        employeeService.updateEmployeeRole(employeeId, request.role());
        return ResponseEntity.noContent().build();
    }

    @PostMapping
    public ResponseEntity<GlobalRespones<Employee>> createEmployee(@RequestBody @Valid EmployeeCreate employee) {
        Employee newEmployee = employeeService.createEmployee(employee);
        return new ResponseEntity<>(new GlobalRespones<>(newEmployee), HttpStatus.CREATED);
    }

    @GetMapping("/department/{departmentId}")
    public ResponseEntity<GlobalRespones<List<Employee>>> getEmployeesByDepartmentId(@PathVariable Long departmentId) {
        List<Employee> employees = employeeService.getEmployeesByDepartmentId(departmentId);
        return new ResponseEntity<>(new GlobalRespones<>(employees), HttpStatus.OK);
    }
}