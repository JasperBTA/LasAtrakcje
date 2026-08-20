package com.las.timeapp.dto;

public class UserCreateRequest {
    private String username;
    private String password;
    private String role;
    private String pin;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPin() { return pin; }
    public void setPin(String pin) { this.pin = pin; }
}
