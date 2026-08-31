package com.las.timeapp.controller;

import com.las.timeapp.entity.Survey;
import com.las.timeapp.repository.SurveyRepository;
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
class SurveyControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SurveyRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    @WithMockUser
    void shouldReturnEmptySurveysList() throws Exception {
        mockMvc.perform(get("/api/surveys"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    @WithMockUser(roles = "WORKER")
    void shouldSyncSurveys() throws Exception {
        String payload = "{" +
                "\"surveys\": [" +
                "  {" +
                "    \"id\": \"survey-1\"," +
                "    \"operatorId\": \"123e4567-e89b-12d3-a456-426614174000\"," +
                "    \"rating\": 5," +
                "    \"strengths\": \"Beautiful scenery\"," +
                "    \"recommendRating\": 10," +
                "    \"source\": \"INTERNET\"," +
                "    \"createdAt\": \"2026-08-25T10:00:00Z\"" +
                "  }" +
                "]" +
                "}";

        mockMvc.perform(post("/api/surveys/sync")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Synced 1 surveys."));
                
        mockMvc.perform(get("/api/surveys"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value("survey-1"))
                .andExpect(jsonPath("$[0].rating").value(5))
                .andExpect(jsonPath("$[0].strengths").value("Beautiful scenery"));
    }
}
