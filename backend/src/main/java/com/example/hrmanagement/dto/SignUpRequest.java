package com.example.hrmanagement.dto;


import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SignUpRequest(
        @NotNull(message = "Username is required") 
        String username,

        @NotNull(message = "Password is required")
        @Size (min = 8, message = "Password must be at least 8 characters long")
        String password

) {

}
