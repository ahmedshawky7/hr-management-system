package com.example.hrmanagement.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.hrmanagement.dto.CurrentUserResponse;
import com.example.hrmanagement.dto.LoginRequest;
import com.example.hrmanagement.dto.ResetPasswordRequest;
import com.example.hrmanagement.dto.SignUpRequest;
import com.example.hrmanagement.service.AuthService;
import com.example.hrmanagement.shared.GlobalRespones;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping("/me")
    public ResponseEntity<GlobalRespones<CurrentUserResponse>> getCurrentUser() {
        return ResponseEntity.ok(new GlobalRespones<>(authService.getCurrentUser()));
    }

    @PostMapping("/login")
    public ResponseEntity<GlobalRespones<String>> login(@RequestBody LoginRequest loginRequest) {

        String token = authService.login(loginRequest);
        return new ResponseEntity<>(new GlobalRespones<>(token), HttpStatus.OK);
    }

    @PostMapping("/signup")
    public ResponseEntity<GlobalRespones<String>> signup(@RequestBody SignUpRequest signUpRequest,
            @RequestParam String token) {
        authService.signUp(signUpRequest, token);
        return new ResponseEntity<>(new GlobalRespones<>("User registered successfully"), HttpStatus.CREATED);
    }

    @PostMapping("/forgot-password/{username}")
    public ResponseEntity<GlobalRespones<String>> initiatePasswordReset(@PathVariable String username) {
        authService.initiatePasswordRest(username);
        return new ResponseEntity<>(new GlobalRespones<>("Password reset link sent successfully"), HttpStatus.CREATED);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<GlobalRespones<String>> resetPassword(
            @RequestBody ResetPasswordRequest resetPasswordRequest) {
        authService.resetPassword(resetPasswordRequest);
        return new ResponseEntity<>(new GlobalRespones<>("Password reset successfully"), HttpStatus.CREATED);
    }

}
