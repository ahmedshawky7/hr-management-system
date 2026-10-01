package com.example.hrmanagement.service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.hrmanagement.config.JwtHelper;
import com.example.hrmanagement.dto.CurrentUserResponse;
import com.example.hrmanagement.dto.LoginRequest;
import com.example.hrmanagement.dto.ResetPasswordRequest;
import com.example.hrmanagement.dto.SignUpRequest;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.entities.PasswordResetToken;
import com.example.hrmanagement.entities.UserAccount;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.PasswordRestRepo;
import com.example.hrmanagement.repository.UserAccountRepo;
import com.example.hrmanagement.shared.CustomResponesException;

@Service
public class AuthService {

        private UserAccountRepo userAccountRepo;
        private EmployeeRepo employeeRepo;
        private final PasswordEncoder passwordEncoder;
        private AuthenticationManager authenticationManager;
        private JwtHelper jwtHelper;
        private PasswordRestRepo passwordRestRepo;
        private EmailService emailService;

        public AuthService(UserAccountRepo userAccountRepo, EmployeeRepo employeeRepo, PasswordEncoder passwordEncoder,
                        AuthenticationManager authenticationManager, JwtHelper jwtHelper,
                        PasswordRestRepo passwordRestRepo,
                        EmailService emailService) {
                this.userAccountRepo = userAccountRepo;
                this.employeeRepo = employeeRepo;
                this.passwordEncoder = passwordEncoder;
                this.authenticationManager = authenticationManager;
                this.jwtHelper = jwtHelper;
                this.passwordRestRepo = passwordRestRepo;
                this.emailService = emailService;
        }

        public void signUp(SignUpRequest signUpRequest, String token) {
                Employee employee = employeeRepo.findByAccountCreationToken(token)
                                .orElseThrow(() -> CustomResponesException
                                                .resourceNotFound("Invalid account creation token"));
                if (employee.isVerified()) {
                        throw CustomResponesException.badRequest("Account already verified");
                }
                UserAccount userAccount = new UserAccount();
                userAccount.setUsername(signUpRequest.username());
                userAccount.setPassword(passwordEncoder.encode(signUpRequest.password()));
                userAccount.setEmployee(employee);

                userAccountRepo.save(userAccount);
                employee.setVerified(true);
                employee.setAccountCreationToken(null);
                employeeRepo.save(employee);

        }

        public String login(LoginRequest loginRequest) {
                authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(loginRequest.username(),
                                                loginRequest.password()));
                UserAccount user = userAccountRepo.findByUsername(loginRequest.username())
                                .orElseThrow(() -> CustomResponesException.badCredentials());
                Map<String, Object> extraClaims = new HashMap<>();
                extraClaims.put("userId", user.getId());
                return jwtHelper.generateToken(extraClaims, user);
        }

        @Transactional
        public void initiatePasswordRest(String username) {

                UserAccount user = userAccountRepo.findByUsername(username)
                                .orElseThrow(() -> CustomResponesException.resourceNotFound("User not found"));
                passwordRestRepo.findByUserId(user.getId())
                                .ifPresent(passwordRestRepo::delete);
                if (user.getEmployee() == null) {
                        throw CustomResponesException.badRequest(
                                        "No email associated with this account");
                }

                String token = UUID.randomUUID().toString();
                LocalDateTime expiryDate = LocalDateTime.now().plusMinutes(15);

                PasswordResetToken passwordResetToken = new PasswordResetToken(token, user, expiryDate);
                passwordRestRepo.save(passwordResetToken);

                try {
                        emailService.sendPasswordRestEmail(user.getEmployee().getEmail(), token);
                } catch (Exception e) {
                        throw CustomResponesException.badRequest(
                                        "Failed to send email: " + e.getMessage());
                }
        }

        public void resetPassword(ResetPasswordRequest resetPasswordRequest) {
                PasswordResetToken passwordResetToken = passwordRestRepo.findOneByToken(resetPasswordRequest.token())
                                .orElseThrow(() -> CustomResponesException.resourceNotFound("Invalid token"));
                boolean isTokenExpired = passwordResetToken.getExpiryDate().isBefore(LocalDateTime.now());
                if (isTokenExpired) {
                        passwordRestRepo.delete(passwordResetToken);
                        throw CustomResponesException.badRequest("Token expired");
                }
                UserAccount user = passwordResetToken.getUser();
                user.setPassword(passwordEncoder.encode(resetPasswordRequest.newPassword()));
                userAccountRepo.save(user);
                passwordRestRepo.delete(passwordResetToken);
        }

        public CurrentUserResponse getCurrentUser() {
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                UserAccount user = userAccountRepo.findByUsername(auth.getName())
                                .orElseThrow(() -> CustomResponesException.resourceNotFound("User not found"));

                Long employeeId = user.getEmployee() != null ? user.getEmployee().getId() : null;

                return new CurrentUserResponse(
                                user.getId(),
                                user.getUsername(),
                                user.getRole(),
                                employeeId);
        }

}
