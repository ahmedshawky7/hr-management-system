package com.example.hrmanagement.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record EmployeeUpdate(

        @NotNull(message = "First name is required") @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters") String firstName,

        @NotNull(message = "Last name is required") @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters") String lastName,

        @NotNull(message = "Phone number is required") @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Phone number should be valid") String phoneNumber,

        @NotNull(message = "Position is required") @Size(min = 2, max = 50, message = "Position must be between 2 and 50 characters") String position,

        Long managerId,
        Boolean clearManager,
        Long departmentId

) {
}