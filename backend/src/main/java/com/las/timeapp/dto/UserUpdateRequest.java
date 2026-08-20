package com.las.timeapp.dto;

public class UserUpdateRequest {
    private String password;
    private String pin;
    private String role;

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPin() { return pin; }
    public void setPin(String pin) { this.pin = pin; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
