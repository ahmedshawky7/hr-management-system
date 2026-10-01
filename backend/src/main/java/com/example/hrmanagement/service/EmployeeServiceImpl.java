package com.example.hrmanagement.service;

import java.util.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.hrmanagement.abstracts.EmployeeService;
import com.example.hrmanagement.dto.EmployeeCreate;
import com.example.hrmanagement.dto.EmployeeUpdate;
import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.entities.UserAccount;
import com.example.hrmanagement.enums.Role;
import com.example.hrmanagement.repository.DepartmentRepo;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.LeaveRequestRepo;
import com.example.hrmanagement.repository.UserAccountRepo;
import com.example.hrmanagement.shared.CustomResponesException;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeRepo employeeRepo;
    private final DepartmentRepo departmentRepo;
    private final EmailService emailService;
    private final UserAccountRepo userAccountRepo;
    private final LeaveRequestRepo leaveRequestRepo;

    EmployeeServiceImpl(EmployeeRepo employeeRepo, DepartmentRepo departmentRepo, EmailService emailService,
            UserAccountRepo userAccountRepo, LeaveRequestRepo leaveRequestRepo) {
        this.employeeRepo = employeeRepo;
        this.departmentRepo = departmentRepo;
        this.emailService = emailService;
        this.userAccountRepo = userAccountRepo;
        this.leaveRequestRepo = leaveRequestRepo;
    }

    @Override
    @PreAuthorize("@securityUtils.isOwner(#employeeId)")
    public Employee findById(Long employeeId) {

        return employeeRepo.findById(employeeId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound(
                        "Employee not found with ID: " + employeeId));
    }

    @Override
    public Page<Employee> getAllEmployees(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return employeeRepo.findAll(pageable);
    }

    @Override
    @Transactional
    public Employee createEmployee(EmployeeCreate employee) {

        Employee newEmployee = new Employee();
        Department department = departmentRepo.findById(employee.departmentId())
                .orElseThrow(() -> CustomResponesException.resourceNotFound(
                        "Department not found with ID: " + employee.departmentId()));
        if (employee.managerId() != null) {
            Employee manager = employeeRepo.findById(employee.managerId())
                    .orElseThrow(() -> CustomResponesException.resourceNotFound(
                            "Manager not found with ID: " + employee.managerId()));
            newEmployee.setManager(manager);

        } else {
            newEmployee.setManager(null);
        }
        String token = UUID.randomUUID().toString();
        newEmployee.setVerified(false);
        newEmployee.setAccountCreationToken(token);
        newEmployee.setFirstName(employee.firstName());
        newEmployee.setLastName(employee.lastName());
        newEmployee.setEmail(employee.email());
        newEmployee.setPhoneNumber(employee.phoneNumber());
        newEmployee.setPosition(employee.position());
        newEmployee.setHireDate(employee.hireDate());
        newEmployee.setDepartment(department);
        employeeRepo.save(newEmployee);

        try {
            emailService.sendAccountCreationEmail(newEmployee.getEmail(), token);
        } catch (Exception e) {
            log.warn("Failed to send account creation email to {}: {}",
                    newEmployee.getEmail(), e.getMessage());
        }

        return newEmployee;

    }

    @Override
    @PreAuthorize("@securityUtils.isOwner(#employeeId)")
    public Employee updateEmployee(Long employeeId, EmployeeUpdate employeeUpdate) {
        Employee existingEmployee = employeeRepo.findById(employeeId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound(
                        "Employee not found with ID: " + employeeId));

        // 🌟 هل اليوزر عنده صلاحية تغيير القسم؟
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean canChangeDepartment = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_SUPER_ADMIN")
                        || a.getAuthority().equals("ROLE_HR_ADMIN")
                        || a.getAuthority().equals("ROLE_MANAGER"));

        // 🌟 نقل القسم (Admin / HR / Manager بس)
        if (employeeUpdate.departmentId() != null) {
            if (!canChangeDepartment) {
                throw CustomResponesException.forbidden(
                        "You are not allowed to change department");
            }
            Department newDepartment = departmentRepo.findById(employeeUpdate.departmentId())
                    .orElseThrow(() -> CustomResponesException.resourceNotFound(
                            "Department not found with ID: " + employeeUpdate.departmentId()));
            existingEmployee.setDepartment(newDepartment);
        }

        // باقي التعديلات (الاسم، الهاتف، الوظيفة) — مسموحة للجميع
        existingEmployee.setFirstName(employeeUpdate.firstName());
        existingEmployee.setLastName(employeeUpdate.lastName());
        existingEmployee.setPhoneNumber(employeeUpdate.phoneNumber());
        existingEmployee.setPosition(employeeUpdate.position());

        // Manager — نفس المنطق
        if (Boolean.TRUE.equals(employeeUpdate.clearManager())) {
            if (!canChangeDepartment) {
                throw CustomResponesException.forbidden(
                        "You are not allowed to change manager");
            }
            existingEmployee.setManager(null);
        } else if (employeeUpdate.managerId() != null) {
            if (!canChangeDepartment) {
                throw CustomResponesException.forbidden(
                        "You are not allowed to change manager");
            }
            Employee manager = employeeRepo.findById(employeeUpdate.managerId())
                    .orElseThrow(() -> CustomResponesException.resourceNotFound("Manager not found"));
            existingEmployee.setManager(manager);
        }

        return employeeRepo.save(existingEmployee);
    }
    @Override
    @Transactional
    public void deleteEmployee(Long employeeId) {
        if (!employeeRepo.existsById(employeeId)) {
            throw CustomResponesException.resourceNotFound(
                    "Employee not found with ID: " + employeeId);
        }
        if (employeeRepo.existsByManagerId(employeeId)) {
            throw CustomResponesException.badRequest(
                    "Cannot delete employee: they manage other employees");
        }
        if (leaveRequestRepo.existsByEmployeeId(employeeId)) {
            throw CustomResponesException.badRequest(
                    "Cannot delete employee: they have leave requests. Consider deactivating instead.");
        }
        userAccountRepo.findByEmployeeId(employeeId)
                .ifPresent(userAccountRepo::delete);
        employeeRepo.deleteById(employeeId);
    }

    @Override
    public List<Employee> getEmployeesByDepartmentId(Long departmentId) {
        return employeeRepo.findByDepartmentId(departmentId);
    }

    @Override
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'HR_ADMIN')")
    public void updateEmployeeRole(Long employeeId, Role role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        var username = auth.getName();
        boolean isHRAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_HR_ADMIN"));
        if (isHRAdmin && role == Role.SUPER_ADMIN) {
            throw CustomResponesException.badRequest("HR Admin cannot promote to SUPER_ADMIN");
        }
        UserAccount user = userAccountRepo.findByEmployeeId(employeeId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound(
                        "User not found with ID: " + employeeId));
        if (username.equals(user.getUsername())) {
            throw CustomResponesException.badRequest("You cannot update your own role");
        }
        user.setRole(role);

        userAccountRepo.save(user);

    }

}