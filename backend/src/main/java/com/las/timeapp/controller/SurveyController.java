package com.las.timeapp.controller;

import com.las.timeapp.entity.Survey;
import com.las.timeapp.repository.SurveyRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/surveys")
public class SurveyController {

    private final SurveyRepository surveyRepository;

    public SurveyController(SurveyRepository surveyRepository) {
        this.surveyRepository = surveyRepository;
    }

    @PostMapping("/sync")
    public ResponseEntity<?> syncSurveys(@RequestBody Map<String, List<Map<String, Object>>> payload, Authentication authentication) {
        List<Map<String, Object>> surveysData = payload.get("surveys");
        if (surveysData == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "No surveys data provided"));
        }

        int syncedCount = 0;

        for (Map<String, Object> data : surveysData) {
            String id = (String) data.get("id");
            if (id == null) continue;

            Optional<Survey> existing = surveyRepository.findById(id);
            if (existing.isEmpty()) {
                Survey survey = new Survey();
                survey.setId(id);
                
                Object operatorIdObj = data.get("operatorId");
                if (operatorIdObj != null) {
                    survey.setOperatorId(java.util.UUID.fromString(operatorIdObj.toString()));
                }

                Object createdAtObj = data.get("createdAt");
                if (createdAtObj != null) {
                    survey.setCreatedAt(OffsetDateTime.parse(createdAtObj.toString()));
                } else {
                    survey.setCreatedAt(OffsetDateTime.now());
                }

                Object ratingObj = data.get("rating");
                if (ratingObj != null) {
                    survey.setRating(Integer.valueOf(ratingObj.toString()));
                }

                survey.setStrengths((String) data.get("strengths"));
                survey.setImprovements((String) data.get("improvements"));

                Object recRatingObj = data.get("recommendRating");
                if (recRatingObj != null) {
                    survey.setRecommendRating(Integer.valueOf(recRatingObj.toString()));
                }

                survey.setSource((String) data.get("source"));
                survey.setSourceOther((String) data.get("sourceOther"));
                survey.setNotes((String) data.get("notes"));

                survey.setSyncStatus("SYNCED");

                surveyRepository.save(survey);
                syncedCount++;
            }
        }

        return ResponseEntity.ok(Map.of("message", "Synced " + syncedCount + " surveys."));
    }
}
