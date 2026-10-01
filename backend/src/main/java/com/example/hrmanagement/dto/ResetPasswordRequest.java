package com.example.hrmanagement.dto;

public record ResetPasswordRequest(
    String token,
    String newPassword
) {
}
