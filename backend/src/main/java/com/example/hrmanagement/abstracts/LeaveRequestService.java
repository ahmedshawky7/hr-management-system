package com.example.hrmanagement.abstracts;

import java.util.List;

import com.example.hrmanagement.dto.LeaveRequestCreate;
import com.example.hrmanagement.entities.LeaveRequest;
import com.example.hrmanagement.enums.LeaveStatus;

public interface LeaveRequestService {

    LeaveRequest createLeaveRequest(LeaveRequestCreate leaveRequestCreate, Long employeeId);
    List<LeaveRequest> getLeaveRequestsByEmployeeId(Long employeeId);
    LeaveRequest updateLeaveStatus(Long leaveRequestId, LeaveStatus status);
    void cancelLeaveRequest(Long leaveRequestId);
    List<LeaveRequest> getPendingLeaveRequests();

    
}
