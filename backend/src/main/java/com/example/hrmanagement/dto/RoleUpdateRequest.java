package com.example.hrmanagement.dto;

import com.example.hrmanagement.enums.Role;

import jakarta.validation.constraints.NotNull;

public record RoleUpdateRequest (
    @NotNull 
    Role role
){
    
}
