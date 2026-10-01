package com.example.hrmanagement.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.hrmanagement.entities.LeaveRequest;
import com.example.hrmanagement.enums.LeaveStatus;

public interface LeaveRequestRepo extends JpaRepository<LeaveRequest, Long> {

    List<LeaveRequest> getAllLeaveRequestByEmployeeId(Long employeeId);

    List<LeaveRequest> findByStatus(LeaveStatus status);

    boolean existsByEmployeeId(Long employeeId);

    @Query("""
            SELECT lr FROM LeaveRequest lr
            WHERE lr.status = :status
              AND lr.employee.manager.id = :managerId
            """)
    List<LeaveRequest> findByStatusAndManagerId(
            @Param("status") LeaveStatus status,
            @Param("managerId") Long managerId);
}
