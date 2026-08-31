package com.las.timeapp.dto;

public class UserUpdateRequest {
    private String password;
    private String pin;
    private String role;
    private String firstName;
    private String lastName;

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPin() { return pin; }
    public void setPin(String pin) { this.pin = pin; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
}
