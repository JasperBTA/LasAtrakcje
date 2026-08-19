package com.las.timeapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.las.timeapp.dto.MeasurementSyncDto;
import com.las.timeapp.dto.SyncRequest;
import com.las.timeapp.model.Measurement;
import com.las.timeapp.repository.MeasurementRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import org.springframework.security.test.context.support.WithMockUser;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SyncControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MeasurementRepository measurementRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser
    void shouldSyncMeasurementsSuccessfully() throws Exception {
        // Arrange
        measurementRepository.deleteAll();

        MeasurementSyncDto dto = new MeasurementSyncDto();
        dto.setId(UUID.randomUUID());
        dto.setOperatorId(UUID.randomUUID());
        dto.setAttractionId(UUID.randomUUID());
        dto.setStartTime(OffsetDateTime.of(2026, 8, 18, 10, 0, 0, 0, ZoneOffset.UTC));
        dto.setStopTime(OffsetDateTime.of(2026, 8, 18, 10, 10, 0, 0, ZoneOffset.UTC));

        SyncRequest request = new SyncRequest();
        request.setMeasurements(List.of(dto));

        // Act & Assert
        mockMvc.perform(post("/api/sync/measurements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SUCCESS"))
                .andExpect(jsonPath("$.syncedCount").value(1));

        // Verify Database state
        List<Measurement> saved = measurementRepository.findAll();
        assertEquals(1, saved.size());
        assertEquals(dto.getId(), saved.get(0).getId());
        assertEquals(600, saved.get(0).getTotalDurationSeconds());
    }
}
