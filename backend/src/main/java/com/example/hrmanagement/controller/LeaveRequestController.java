package com.example.hrmanagement.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.hrmanagement.abstracts.LeaveRequestService;
import com.example.hrmanagement.dto.LeaveRequestCreate;
import com.example.hrmanagement.dto.LeaveStatusUpdateRequest;
import com.example.hrmanagement.entities.LeaveRequest;
import com.example.hrmanagement.shared.GlobalRespones;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/leave-requests")
public class LeaveRequestController {

    private final LeaveRequestService leaveRequestService;

    public LeaveRequestController(LeaveRequestService leaveRequestService) {
        this.leaveRequestService = leaveRequestService;
    }

    @PostMapping("/employee/{employeeId}")
    public ResponseEntity<GlobalRespones<LeaveRequest>> createLeaveRequest(
            @PathVariable Long employeeId,
            @RequestBody @Valid LeaveRequestCreate leaveRequestCreate) {

        LeaveRequest newLeaveRequest =
                leaveRequestService.createLeaveRequest(
                        leaveRequestCreate,
                        employeeId
                );

        return new ResponseEntity<>(
                new GlobalRespones<>(newLeaveRequest),
                HttpStatus.CREATED
        );
    }

    @GetMapping("/employee/{employeeId}")
    public ResponseEntity<GlobalRespones<List<LeaveRequest>>> getLeaveRequestsByEmployeeId(
            @PathVariable Long employeeId) {

        List<LeaveRequest> leaveRequests =
                leaveRequestService.getLeaveRequestsByEmployeeId(employeeId);

        return ResponseEntity.ok(
                new GlobalRespones<>(leaveRequests)
        );
    }

    @PutMapping("/{leaveRequestId}/status")
    public ResponseEntity<GlobalRespones<LeaveRequest>> updateLeaveStatus(
            @PathVariable Long leaveRequestId,
            @RequestBody @Valid LeaveStatusUpdateRequest request) {

        LeaveRequest updated =
                leaveRequestService.updateLeaveStatus(
                        leaveRequestId,
                        request.status()
                );

        return ResponseEntity.ok(
                new GlobalRespones<>(updated)
        );
    }

    @PutMapping("/{leaveRequestId}/cancel")
    public ResponseEntity<Void> cancelLeaveRequest(
            @PathVariable Long leaveRequestId) {

        leaveRequestService.cancelLeaveRequest(leaveRequestId);

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/pending")
    public ResponseEntity<GlobalRespones<List<LeaveRequest>>> getPendingLeaveRequests() {

        List<LeaveRequest> pending =
                leaveRequestService.getPendingLeaveRequests();

        return ResponseEntity.ok(
                new GlobalRespones<>(pending)
        );
    }
}