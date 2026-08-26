package com.las.timeapp.controller;

import com.las.timeapp.model.GlobalSettings;
import com.las.timeapp.repository.GlobalSettingsRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class GlobalSettingsControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private GlobalSettingsRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
        GlobalSettings defaults = new GlobalSettings(50, 4, 45, 10);
        repository.save(defaults);
    }

    @Test
    @WithMockUser
    void shouldReturnDefaultSettings() throws Exception {
        mockMvc.perform(get("/api/settings"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.gpsAccuracyThreshold").value(50))
                .andExpect(jsonPath("$.entryBufferSeconds").value(4));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldUpdateSettings() throws Exception {
        String newSettingsJson = "{" +
                "\"gpsAccuracyThreshold\": 30," +
                "\"entryBufferSeconds\": 10," +
                "\"exitBufferSeconds\": 60," +
                "\"hysteresisMargin\": 15" +
                "}";

        mockMvc.perform(post("/api/settings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(newSettingsJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.gpsAccuracyThreshold").value(30))
                .andExpect(jsonPath("$.entryBufferSeconds").value(10));
    }
}
