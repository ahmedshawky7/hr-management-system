package com.example.hrmanagement.service;

import java.time.LocalDate;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.entities.UserAccount;
import com.example.hrmanagement.enums.Role;
import com.example.hrmanagement.repository.DepartmentRepo;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.UserAccountRepo;

import lombok.extern.slf4j.Slf4j;
@Slf4j
@Configuration
public class AdminUserInitializer {

    @Bean
    public CommandLineRunner createAdminUser(
            UserAccountRepo userRepository,
            PasswordEncoder passwordEncoder,
            DepartmentRepo departmentRepo,
            EmployeeRepo employeeRepo) {

        return args -> {
            if (userRepository.findByUsername("admin").isPresent()) {
                return;
            }

            Department department = departmentRepo.findByName("Administration")
                    .orElseGet(() -> {

                        Department newDepartment = new Department();
                        newDepartment.setName("Administration");

                        return departmentRepo.save(newDepartment);
                    });

            Employee adminEmployee = new Employee();

            adminEmployee.setFirstName("System");
            adminEmployee.setLastName("Administrator");
            adminEmployee.setEmail("admin@company.com");
            adminEmployee.setPhoneNumber("+201000000000");
            adminEmployee.setPosition("System Administrator");
            adminEmployee.setHireDate(LocalDate.now());
            adminEmployee.setDepartment(department);

            adminEmployee.setVerified(true);
            adminEmployee.setAccountCreationToken(null);

            employeeRepo.save(adminEmployee);

            UserAccount admin = new UserAccount();

            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin1234"));
            admin.setRole(Role.SUPER_ADMIN);
            admin.setEmployee(adminEmployee);

            userRepository.save(admin);
            log.info("Default SUPER_ADMIN 'admin' created successfully");
        };
    }
}