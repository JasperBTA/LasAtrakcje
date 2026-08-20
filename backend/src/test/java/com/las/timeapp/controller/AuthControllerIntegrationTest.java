package com.las.timeapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.las.timeapp.dto.AuthRequest;
import com.las.timeapp.dto.PinAuthRequest;
import com.las.timeapp.model.User;
import com.las.timeapp.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();

        User user = new User();
        user.setId(UUID.randomUUID());
        user.setUsername("testOperator");
        user.setPasswordHash(passwordEncoder.encode("superSecretPassword"));
        user.setPinHash(passwordEncoder.encode("1234"));
        user.setCreatedAt(OffsetDateTime.now(ZoneOffset.UTC));
        userRepository.save(user);
    }

    @Test
    void shouldLoginSuccessfullyWithValidCredentials() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setUsername("testOperator");
        request.setPassword("superSecretPassword");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.username").value("testOperator"));
    }

    @Test
    void shouldFailLoginWithInvalidPassword() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setUsername("testOperator");
        request.setPassword("wrongPassword");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void shouldFailLoginWithUnknownUser() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setUsername("unknownUser");
        request.setPassword("superSecretPassword");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void shouldLoginSuccessfullyWithValidPin() throws Exception {
        PinAuthRequest request = new PinAuthRequest();
        request.setPin("1234");

        mockMvc.perform(post("/api/auth/login-pin")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.username").value("testOperator"));
    }

    @Test
    void shouldFailLoginWithInvalidPin() throws Exception {
        PinAuthRequest request = new PinAuthRequest();
        request.setPin("9999");

        mockMvc.perform(post("/api/auth/login-pin")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }
}
