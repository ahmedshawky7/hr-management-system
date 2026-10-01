package com.example.hrmanagement.dto;

import java.util.List;

public record PaginatedResponse<T>(
    List<T> content,
    int currentPage,
    int totalPages,
    long totalItems,
    boolean hasNext,
    boolean hasPrevious,
    String nextPageUrl,
    String previousPageUrl
) {
}
