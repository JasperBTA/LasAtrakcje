package com.las.timeapp.controller;

import com.las.timeapp.model.Attraction;
import com.las.timeapp.model.Measurement;
import com.las.timeapp.model.User;
import com.las.timeapp.repository.AttractionRepository;
import com.las.timeapp.repository.MeasurementRepository;
import com.las.timeapp.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ExportControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MeasurementRepository measurementRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AttractionRepository attractionRepository;

    private UUID userId;
    private UUID attractionId;

    @BeforeEach
    void setUp() {
        measurementRepository.deleteAll();
        userRepository.deleteAll();
        attractionRepository.deleteAll();

        // Dodanie testowego użytkownika
        User user = new User();
        user.setUsername("TestowyPracownik");
        user.setPasswordHash("hash");
        user = userRepository.save(user);
        userId = user.getId();

        // Dodanie testowej atrakcji
        Attraction attraction = new Attraction();
        attraction.setName("Wieza Widokowa");
        attraction.setLatitude(50.0);
        attraction.setLongitude(20.0);
        attraction.setRadius(50.0);
        attraction.setIsActive(true);
        attraction = attractionRepository.save(attraction);
        attractionId = attraction.getId();

        // Dodanie testowego pomiaru
        Measurement m = new Measurement();
        m.setId(UUID.randomUUID());
        m.setOperatorId(userId);
        m.setAttractionId(attractionId);
        m.setStartTime(OffsetDateTime.of(2026, 8, 20, 10, 0, 0, 0, ZoneOffset.UTC));
        m.setStopTime(OffsetDateTime.of(2026, 8, 20, 11, 0, 0, 0, ZoneOffset.UTC));
        m.setTotalDurationSeconds(3600);
        m.setSyncStatus("SYNCED");
        measurementRepository.save(m);
    }

    @Test
    @WithMockUser
    void shouldExportJsonData() throws Exception {
        mockMvc.perform(get("/api/export/measurements/json"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith("application/json"))
                .andExpect(jsonPath("$[0].operatorId").value(userId.toString()))
                .andExpect(jsonPath("$[0].totalDurationSeconds").value(3600));
    }

    @Test
    @WithMockUser
    void shouldExportCsvDataWithNamesReplaced() throws Exception {
        mockMvc.perform(get("/api/export/measurements/csv"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith("text/csv"))
                .andExpect(header().string("Content-Disposition", "attachment; filename=\"measurements_export.csv\""))
                // CSV nie powinno pokazywać UUID, tylko zamienione nazwy: "TestowyPracownik" oraz "Wieza Widokowa"
                .andExpect(content().string(containsString("TestowyPracownik")))
                .andExpect(content().string(containsString("Wieza Widokowa")))
                .andExpect(content().string(containsString("3600")))
                .andExpect(content().string(containsString("SYNCED")));
    }
}
