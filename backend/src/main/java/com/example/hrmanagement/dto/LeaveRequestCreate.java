package com.example.hrmanagement.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record LeaveRequestCreate(

        @NotNull(message = "Reason is required")
        @Size(min = 2, max = 50, message = "Reason must be between 2 and 50 characters")
        String reason,

        @NotNull(message = "Start date is required")
        @FutureOrPresent(message = "Start date must be in the future or present")
        LocalDate startDate,

        @NotNull(message = "End date is required")
        @FutureOrPresent(message = "End date must be in the future or present")
        LocalDate endDate
) {

    @AssertTrue(message = "End date must be after or equal to start date")
    public boolean isDateRangeValid() {
        if (startDate == null || endDate == null) {
            return true; 
        }
        return !endDate.isBefore(startDate);
    }
}