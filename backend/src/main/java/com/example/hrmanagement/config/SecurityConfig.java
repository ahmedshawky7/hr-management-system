package com.example.hrmanagement.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.example.hrmanagement.enums.Role;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

        private final UserDetailsService userDetailsService;
        private final JwtAuthFilter jwtAuthFilter;

        SecurityConfig(UserDetailsService userDetailsService, JwtAuthFilter jwtAuthFilter) {
                this.userDetailsService = userDetailsService;
                this.jwtAuthFilter = jwtAuthFilter;
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
                return new BCryptPasswordEncoder();
        }

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .cors(c -> {
                                        CorsConfigurationSource source = corsConfigurationSource();
                                        c.configurationSource(source);
                                })
                                .csrf(AbstractHttpConfigurer::disable)
                                .authorizeHttpRequests(auth -> auth
                                                // ===== Public endpoints =====
                                                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                                                .requestMatchers(
                                                                "/auth/signup",
                                                                "/auth/login",
                                                                "/auth/forgot-password/{username}",
                                                                "/auth/reset-password")
                                                .permitAll()
                                                .requestMatchers("/auth/me").authenticated()

                                                // ===== Admin-only endpoints=====
                                                .requestMatchers(HttpMethod.PUT, "/employees/{employeeId}/role")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name())

                                                // ===== Department-scoped endpoints =====
                                                .requestMatchers(HttpMethod.GET, "/employees/department/{departmentId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name())

                                                // ===== Employee general endpoints =====
                                                .requestMatchers(HttpMethod.GET, "/employees")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name())

                                                .requestMatchers(HttpMethod.GET, "/employees/{employeeId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                .requestMatchers(HttpMethod.POST, "/employees")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name())

                                                .requestMatchers(HttpMethod.DELETE, "/employees/{employeeId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name())

                                                .requestMatchers(HttpMethod.PUT, "/employees/{employeeId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                // ===== Departments =====
                                                .requestMatchers(HttpMethod.GET, "/departments")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                .requestMatchers(HttpMethod.POST, "/departments")
                                                .hasRole(Role.SUPER_ADMIN.name())

                                                .requestMatchers(HttpMethod.DELETE, "/departments/{departmentId}")
                                                .hasRole(Role.SUPER_ADMIN.name())

                                                .requestMatchers(HttpMethod.GET, "/departments/{departmentId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                // ===== Leave requests =====
                                                .requestMatchers(HttpMethod.POST,
                                                                "/leave-requests/employee/{employeeId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                .requestMatchers(HttpMethod.GET,
                                                                "/leave-requests/employee/{employeeId}")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                .requestMatchers(HttpMethod.PUT,
                                                                "/leave-requests/{leaveRequestId}/status")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name())

                                                .requestMatchers(HttpMethod.PUT,
                                                                "/leave-requests/{leaveRequestId}/cancel")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name(), Role.EMPLOYEE.name())

                                                .requestMatchers(HttpMethod.GET, "/leave-requests/pending")
                                                .hasAnyRole(Role.SUPER_ADMIN.name(), Role.HR_ADMIN.name(),
                                                                Role.MANAGER.name())

                                                // ===== All other requests =====
                                                .anyRequest().authenticated())
                                .exceptionHandling(ex -> ex
                                                .authenticationEntryPoint((request, response, authException) -> {
                                                        log.debug("Authentication failed for {}: {}",
                                                                        request.getRequestURI(),
                                                                        authException.getMessage());
                                                        response.setStatus(401);
                                                        response.setContentType("application/json");
                                                        response.getWriter().write(
                                                                        "{\"status\":\"Error\",\"errors\":[{\"message\":\"Authentication required\"}]}");
                                                })
                                                .accessDeniedHandler((request, response, accessDeniedException) -> {
                                                        log.debug("Access denied for {}: {}",
                                                                        request.getRequestURI(),
                                                                        accessDeniedException.getMessage());
                                                        response.setStatus(403);
                                                        response.setContentType("application/json");
                                                        response.getWriter().write(
                                                                        "{\"status\":\"Error\",\"errors\":[{\"message\":\"Access denied - insufficient permissions\"}]}");
                                                }))
                                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                                .authenticationManager(authenticationManager(http));

                return http.build();
        }

        @Bean
        AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
                var authBuilder = http.getSharedObject(AuthenticationManagerBuilder.class);
                authBuilder.userDetailsService(userDetailsService).passwordEncoder(passwordEncoder());
                return authBuilder.build();
        }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();

                // 🌟 استخدم Patterns بدل Origins
                configuration.setAllowedOriginPatterns(List.of(
                                "http://localhost", // 🌟 جديد — بدون port
                                "http://127.0.0.1", // 🌟 جديد
                                "http://localhost:*", // مع port (أي رقم)
                                "http://127.0.0.1:*",
                                "https://*.onrender.com",
                                "https://*.railway.app",
                                "https://*.netlify.app"));

                configuration.setAllowedMethods(List.of(
                                "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
                configuration.setAllowedHeaders(List.of("*"));
                configuration.setAllowCredentials(true);
                configuration.setMaxAge(3600L);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}