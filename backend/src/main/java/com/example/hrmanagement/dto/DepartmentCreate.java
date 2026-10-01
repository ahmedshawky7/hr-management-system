package com.example.hrmanagement.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record DepartmentCreate(
    @NotNull(message = "Name is required")
    @Size (min = 2, max = 50, message = "Name must be between 2 and 50 characters")
     String name

) {
    
}
