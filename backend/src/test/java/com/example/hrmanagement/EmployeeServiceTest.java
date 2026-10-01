package com.example.hrmanagement;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.hrmanagement.dto.EmployeeCreate;
import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.repository.DepartmentRepo;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.LeaveRequestRepo;
import com.example.hrmanagement.repository.UserAccountRepo;
import com.example.hrmanagement.service.EmailService;
import com.example.hrmanagement.service.EmployeeServiceImpl;
import com.example.hrmanagement.shared.CustomResponesException;

@ExtendWith(MockitoExtension.class)
class EmployeeServiceTest {

    @Mock private DepartmentRepo departmentRepo;
    @Mock private EmployeeRepo employeeRepo;
    @Mock private EmailService emailService;
    @Mock private UserAccountRepo userAccountRepo;    
    @Mock private LeaveRequestRepo leaveRequestRepo;   

    @InjectMocks
    private EmployeeServiceImpl employeeService;

    private Department testDepartment;
    private Long departmentId;
    private EmployeeCreate employeeCreate;

    @BeforeEach
    void setUp() {
        departmentId = 1L;
        testDepartment = new Department(departmentId, "IT");
        employeeCreate = new EmployeeCreate(
                "John",
                "Doe",
                "john@example.com",
                "1234567890",
                "Developer",
                LocalDate.now(),
                departmentId,
                null
        );
    }

    @Test
    @DisplayName("createEmployee — success case")
    void createEmployee_shouldSucceed() {
        when(departmentRepo.findById(departmentId))
                .thenReturn(Optional.of(testDepartment));
        when(employeeRepo.save(any(Employee.class)))
                .thenAnswer(i -> i.getArgument(0));
        Employee result = employeeService.createEmployee(employeeCreate);

        assertNotNull(result);
        assertEquals("John", result.getFirstName());
        assertEquals("Doe", result.getLastName());
        assertEquals("john@example.com", result.getEmail());
        assertEquals(testDepartment, result.getDepartment());
        assertFalse(result.isVerified());
        assertNotNull(result.getAccountCreationToken());

        verify(employeeRepo, times(1)).save(any(Employee.class));
        verify(emailService, times(1))
                .sendAccountCreationEmail(eq("john@example.com"), any(String.class));
    }

    @Test
    @DisplayName("createEmployee — throws when department not found")
    void createEmployee_shouldThrowWhenDepartmentNotFound() {
        when(departmentRepo.findById(departmentId)).thenReturn(Optional.empty());

        CustomResponesException ex = assertThrows(
                CustomResponesException.class,
                () -> employeeService.createEmployee(employeeCreate)
        );

        assertTrue(ex.getMessage().contains("Department not found"));

        verify(emailService, never())
                .sendAccountCreationEmail(any(String.class), any(String.class));
        verify(employeeRepo, never()).save(any(Employee.class));
    }
}