package com.example.hrmanagement;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.example.hrmanagement.abstracts.EmployeeService;
import com.example.hrmanagement.abstracts.LeaveRequestService;
import com.example.hrmanagement.config.JwtHelper;
import com.example.hrmanagement.controller.EmployeeController;
import com.example.hrmanagement.entities.Department;
import com.example.hrmanagement.entities.Employee;

@WebMvcTest(EmployeeController.class)
public class EmployeeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private EmployeeService employeeService;

    @MockitoBean
    private JwtHelper jwtHelper;

    @MockitoBean
    private LeaveRequestService leaveRequestService;

    @MockitoBean
    private UserDetailsService userDetailsService;

    @Test
    public void shouldReturnAllEmployees() throws Exception {

        Department department = new Department();
        department.setId(1L);
        department.setName("IT");

        Employee employee = new Employee();
        employee.setId(1L);
        employee.setFirstName("John");
        employee.setLastName("Doe");
        employee.setEmail("john@gmail.com");
        employee.setPhoneNumber("01154544564");
        employee.setHireDate(LocalDate.now());
        employee.setPosition("developer");
        employee.setVerified(false);
        employee.setDepartment(department);

        List<Employee> employees = List.of(employee);

        Page<Employee> employeesPage = new PageImpl<>(employees);

        when(employeeService.getAllEmployees(0, 3))
                .thenReturn(employeesPage);

        mockMvc.perform(
                get("/employees")
                        .param("page", "1")
                        .param("size", "3")
                        .with(user("admin").roles("SUPER_ADMIN")))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("Success"))
                .andExpect(jsonPath("$.data.content[0].firstName").value("John"))
                .andExpect(jsonPath("$.data.content[0].email").value("john@gmail.com"));
    }
}