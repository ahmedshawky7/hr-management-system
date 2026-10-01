package com.example.hrmanagement.dto;

import com.example.hrmanagement.enums.Role;

public record CurrentUserResponse(
    Long id,
    String username,
    Role role,
    Long employeeId
) {}