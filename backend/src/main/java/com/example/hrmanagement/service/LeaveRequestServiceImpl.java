package com.example.hrmanagement.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.example.hrmanagement.abstracts.LeaveRequestService;
import com.example.hrmanagement.dto.LeaveRequestCreate;
import com.example.hrmanagement.entities.Employee;
import com.example.hrmanagement.entities.LeaveRequest;
import com.example.hrmanagement.entities.UserAccount;
import com.example.hrmanagement.enums.LeaveStatus;
import com.example.hrmanagement.enums.Role;
import com.example.hrmanagement.repository.EmployeeRepo;
import com.example.hrmanagement.repository.LeaveRequestRepo;
import com.example.hrmanagement.repository.UserAccountRepo;
import com.example.hrmanagement.shared.CustomResponesException;
import com.example.hrmanagement.utils.SecurityUtils;

@Service
public class LeaveRequestServiceImpl implements LeaveRequestService {

    private LeaveRequestRepo leaveRequestRepo;
    private EmployeeRepo employeeRepo;
    private SecurityUtils securityUtils;
    private UserAccountRepo userAccountRepo;

    public LeaveRequestServiceImpl(LeaveRequestRepo leaveRequestRepo, EmployeeRepo employeeRepo,
            SecurityUtils securityUtils, UserAccountRepo userAccountRepo) {
        this.leaveRequestRepo = leaveRequestRepo;
        this.employeeRepo = employeeRepo;
        this.securityUtils = securityUtils;
        this.userAccountRepo = userAccountRepo;
    }

    @Override
    @PreAuthorize("@securityUtils.isOwner(#employeeId)")
    public LeaveRequest createLeaveRequest(LeaveRequestCreate leaveRequestCreate, Long employeeId) {
        Employee employee = employeeRepo.findById(employeeId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound("Employee not found"));
        LeaveRequest leaveRequest = new LeaveRequest();

        leaveRequest.setStatus(LeaveStatus.PENDING);
        leaveRequest.setReason(leaveRequestCreate.reason());
        leaveRequest.setStartDate(leaveRequestCreate.startDate());
        leaveRequest.setEndDate(leaveRequestCreate.endDate());
        leaveRequest.setEmployee(employee);
        return leaveRequestRepo.save(leaveRequest);
    }

    @Override
    @PreAuthorize("@securityUtils.isOwner(#employeeId)")
    public List<LeaveRequest> getLeaveRequestsByEmployeeId(Long employeeId) {

        return leaveRequestRepo.getAllLeaveRequestByEmployeeId(employeeId);
    }

    @Override
    public LeaveRequest updateLeaveStatus(Long leaveRequestId, LeaveStatus status) {

        LeaveRequest leaveRequest = leaveRequestRepo.findById(leaveRequestId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound("Leave request not found"));
        Long employeeId = leaveRequest.getEmployee().getId();
        if (!securityUtils.canApproveLeave(employeeId)) {
            throw CustomResponesException.forbidden("You are not allowed to approve this leave request");
        }
        if (leaveRequest.getStatus() != LeaveStatus.PENDING) {
            throw CustomResponesException.badRequest("Only PENDING leave requests can be updated");
        }

        if (status != LeaveStatus.APPROVED && status != LeaveStatus.REJECTED) {
            throw CustomResponesException.badRequest("Status must be APPROVED or REJECTED");
        }

        leaveRequest.setStatus(status);
        return leaveRequestRepo.save(leaveRequest);
    }

    @Override
    public void cancelLeaveRequest(Long leaveRequestId) {
        LeaveRequest leaveRequest = leaveRequestRepo.findById(leaveRequestId)
                .orElseThrow(() -> CustomResponesException.resourceNotFound("Leave request not found"));
        Long employeeId = leaveRequest.getEmployee().getId();
        if (!securityUtils.isSelf(employeeId)) {
            throw CustomResponesException.forbidden("You are not allowed to cancel this leave request");
        }
        if (leaveRequest.getStatus() != LeaveStatus.PENDING) {
            throw CustomResponesException.badRequest("Only PENDING leave requests can be cancelled");
        }
        leaveRequest.setStatus(LeaveStatus.CANCELLED);
        leaveRequestRepo.save(leaveRequest);
    }

    @Override
    public List<LeaveRequest> getPendingLeaveRequests() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = auth.getName();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.SUPER_ADMIN)
                        || a.getAuthority().equals("ROLE_" + Role.HR_ADMIN));
        if (isAdmin) {
            return leaveRequestRepo.findByStatus(LeaveStatus.PENDING);
        }
        boolean isManager= auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + Role.MANAGER));
        if (isManager) {
            UserAccount manager= userAccountRepo.findByUsername(currentUsername).orElseThrow(() -> CustomResponesException.resourceNotFound("User not found"));
            if (manager.getEmployee() != null) {
                Long managerId = manager.getEmployee().getId();

                return leaveRequestRepo.findByStatusAndManagerId(LeaveStatus.PENDING, managerId);
                
            }else{
                throw CustomResponesException.badRequest("Manager account is not linked to an employee");
            }
            
            
        }

        throw CustomResponesException.forbidden("You are not allowed to view pending leave requests");
    }

}
