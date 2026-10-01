package com.example.hrmanagement.utils;

import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import com.example.hrmanagement.entities.UserAccount;
import com.example.hrmanagement.enums.Role;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.UserAccountRepo;

@Component
public class SecurityUtils {

    private final UserAccountRepo userAccountRepo;
    private final EmployeeRepo employeeRepo;

    public SecurityUtils(UserAccountRepo userAccountRepo, EmployeeRepo employeeRepo) {
        this.userAccountRepo = userAccountRepo;
        this.employeeRepo = employeeRepo;
    }

    public boolean isOwner(Long incomingEmployeeId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = auth.getName();

        // 1) SUPER_ADMIN / HR_ADMIN → full access
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.SUPER_ADMIN)
                        || a.getAuthority().equals("ROLE_" + Role.HR_ADMIN));
        if (isAdmin) {
            return true;
        }

        // 2) MANAGER → direct reports only
        boolean isManager = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.MANAGER));

        if (isManager) {
            Optional<UserAccount> managerUserOpt = userAccountRepo.findByUsername(currentUsername);
            if (managerUserOpt.isPresent() && managerUserOpt.get().getEmployee() != null) {
                Long managerEmpId = managerUserOpt.get().getEmployee().getId();
                boolean isDirectReport = employeeRepo.isDirectReport(managerEmpId, incomingEmployeeId);
                if (isDirectReport) {
                    return true;
                }
            }
        }

        // 3) Self access
        UserDetails currentUser = (UserDetails) auth.getPrincipal();
        return userAccountRepo.isOwner(currentUser.getUsername(), incomingEmployeeId);
    }

    public boolean canApproveLeave(Long employeeId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = auth.getName();

        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.SUPER_ADMIN)
                        || a.getAuthority().equals("ROLE_" + Role.HR_ADMIN));
        if (isAdmin) {
            return true;
        }

        boolean isManager = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.MANAGER));

        if (isManager) {
            Optional<UserAccount> managerUserOpt = userAccountRepo.findByUsername(currentUsername);
            if (managerUserOpt.isPresent() && managerUserOpt.get().getEmployee() != null) {
                Long managerEmpId = managerUserOpt.get().getEmployee().getId();
                return employeeRepo.isDirectReport(managerEmpId, employeeId);
            }
        }

        return false;
    }

    public boolean isSelf(Long employeeId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return userAccountRepo.isOwner(auth.getName(), employeeId);
    }
}