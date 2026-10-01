package com.example.hrmanagement.shared;

import java.util.List;

public class GlobalRespones<T> {
    public final static String SUCCESS = "Success";
    public final static String ERROR = "Error";

    private final String status;
    private final T data;
    private final List<ErrorItem> errors;

    public record ErrorItem(String message){}

    public GlobalRespones(List<ErrorItem> errors) {
        this.status = ERROR;
        this.data = null;
        this.errors = errors;
    }

    public GlobalRespones(T data) {
        this.status = SUCCESS;
        this.data = data;
        this.errors = null;
    }

    public String getStatus() {
        return status;
    }

    public T getData() {
        return data;
    }

    public List<ErrorItem> getErrors() {
        return errors;
    }
}
