package com.las.timeapp;

import com.las.timeapp.model.User;
import com.las.timeapp.repository.UserRepository;
import com.las.timeapp.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class SecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserRepository userRepository;

    private String adminToken;
    private String workerToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();

        // Create Admin
        User admin = new User();
        admin.setUsername("testadmin");
        admin.setPasswordHash("hashed");
        admin.setRole("ADMIN");
        userRepository.save(admin);
        adminToken = jwtUtil.generateToken(admin.getId(), admin.getUsername(), admin.getRole());

        // Create Worker
        User worker = new User();
        worker.setUsername("testworker");
        worker.setPasswordHash("hashed");
        worker.setRole("WORKER");
        userRepository.save(worker);
        workerToken = jwtUtil.generateToken(worker.getId(), worker.getUsername(), worker.getRole());
    }

    @Test
    void testUnauthorizedAccessToAdminPanel_NoToken() throws Exception {
        mockMvc.perform(get("/api/admin/users"))
               .andExpect(status().isForbidden());
    }

    @Test
    void testForbiddenAccessToAdminPanel_WorkerToken() throws Exception {
        mockMvc.perform(get("/api/admin/users")
               .header("Authorization", "Bearer " + workerToken))
               .andExpect(status().isForbidden());
    }

    @Test
    void testSuccessAccessToAdminPanel_AdminToken() throws Exception {
        mockMvc.perform(get("/api/admin/users")
               .header("Authorization", "Bearer " + adminToken))
               .andExpect(status().isOk());
    }
}
