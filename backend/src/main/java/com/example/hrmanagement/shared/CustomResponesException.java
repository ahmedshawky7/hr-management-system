package com.example.hrmanagement.shared;

public class CustomResponesException extends RuntimeException {
    private int statusCode;
    private String message;

    public CustomResponesException(int statusCode, String message) {
        this.statusCode = statusCode;
        this.message = message;
    }

    public static CustomResponesException resourceNotFound(String message) {
        return new CustomResponesException(404, message);
    }

    public static CustomResponesException badRequest(String message) {
        return new CustomResponesException(400, message);
    }

    public static CustomResponesException badCredentials() {
        return new CustomResponesException(401, "Bad credentials");
    }

    public static CustomResponesException forbidden(String message) {
        return new CustomResponesException(403, message);
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getMessage() {
        return message;
    }
}
