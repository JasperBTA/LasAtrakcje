package com.las.timeapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.las.timeapp.model.Attraction;
import com.las.timeapp.repository.AttractionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.hamcrest.Matchers.hasSize;

@SpringBootTest
@AutoConfigureMockMvc
class AttractionControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AttractionRepository attractionRepository;

    @BeforeEach
    void setUp() {
        attractionRepository.deleteAll();

        Attraction activeAttraction = new Attraction();
        activeAttraction.setId(UUID.randomUUID());
        activeAttraction.setName("Active Attraction");
        activeAttraction.setLatitude(50.0);
        activeAttraction.setLongitude(20.0);
        activeAttraction.setRadius(100.0);
        activeAttraction.setIsActive(true);
        activeAttraction.setCreatedAt(OffsetDateTime.now(ZoneOffset.UTC));
        attractionRepository.save(activeAttraction);

        Attraction inactiveAttraction = new Attraction();
        inactiveAttraction.setId(UUID.randomUUID());
        inactiveAttraction.setName("Inactive Attraction");
        inactiveAttraction.setLatitude(51.0);
        inactiveAttraction.setLongitude(21.0);
        inactiveAttraction.setRadius(50.0);
        inactiveAttraction.setIsActive(false);
        inactiveAttraction.setCreatedAt(OffsetDateTime.now(ZoneOffset.UTC));
        attractionRepository.save(inactiveAttraction);
    }

    @Test
    @WithMockUser
    void shouldReturnOnlyActiveAttractionsForAuthenticatedUser() throws Exception {
        mockMvc.perform(get("/api/attractions")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Active Attraction"));
    }

    @Test
    void shouldReturnForbiddenForUnauthenticatedUser() throws Exception {
        mockMvc.perform(get("/api/attractions")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden()); // By default Spring Security returns 403 when no auth is provided and CSRF is disabled
    }
}
