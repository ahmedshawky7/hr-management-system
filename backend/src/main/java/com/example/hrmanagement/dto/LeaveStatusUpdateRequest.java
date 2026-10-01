package com.example.hrmanagement.dto;

import com.example.hrmanagement.enums.LeaveStatus;

import jakarta.validation.constraints.NotNull;

public record LeaveStatusUpdateRequest(
        @NotNull LeaveStatus status) {
}
