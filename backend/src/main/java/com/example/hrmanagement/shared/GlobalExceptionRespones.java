package com.example.hrmanagement.shared;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@ControllerAdvice
public class GlobalExceptionRespones {

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<GlobalRespones<?>> handleNoResourceException(Exception ex) {
        // Handle the exception and return a response entity
        var errors = List.of(
                new GlobalRespones.ErrorItem("Resource not found"));
        return new ResponseEntity<>(new GlobalRespones<>(errors), HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(CustomResponesException.class)
    public ResponseEntity<GlobalRespones<?>> handleCustomResponesException(CustomResponesException ex) {
        var errors = List.of(
                new GlobalRespones.ErrorItem(ex.getMessage()));
        return new ResponseEntity<>(new GlobalRespones<>(errors), HttpStatus.valueOf(ex.getStatusCode()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<GlobalRespones<?>> handleValidationException(MethodArgumentNotValidException ex) {
        var errors = ex.getBindingResult().getFieldErrors().stream()
                .map(error -> new GlobalRespones.ErrorItem(error.getField() + " : " + error.getDefaultMessage()))
                .toList();
        return new ResponseEntity<>(new GlobalRespones<>(errors), HttpStatus.BAD_REQUEST);
    }
}