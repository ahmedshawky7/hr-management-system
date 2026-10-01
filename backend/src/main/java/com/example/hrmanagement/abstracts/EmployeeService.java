package com.example.hrmanagement.abstracts;

import java.util.*;

import org.springframework.data.domain.Page;

import com.example.hrmanagement.dto.EmployeeCreate;
import com.example.hrmanagement.dto.EmployeeUpdate;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.enums.Role;

public interface EmployeeService {

    Employee findById(Long employeeId);
    Page<Employee> getAllEmployees(int page, int size);
    Employee createEmployee(EmployeeCreate employee);
    Employee updateEmployee(Long employeeId ,EmployeeUpdate employee);
    void deleteEmployee(Long employeeId);
    List<Employee> getEmployeesByDepartmentId(Long departmentId);
    void updateEmployeeRole(Long employeeId, Role role);

}
