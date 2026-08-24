package com.las.timeapp.controller;

import com.las.timeapp.model.Measurement;
import com.las.timeapp.model.User;
import com.las.timeapp.model.Attraction;
import com.las.timeapp.repository.MeasurementRepository;
import com.las.timeapp.repository.UserRepository;
import com.las.timeapp.repository.AttractionRepository;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.las.timeapp.repository.SurveyRepository;

@RestController
@RequestMapping("/api/export")
public class ExportController {

    private final MeasurementRepository measurementRepository;
    private final UserRepository userRepository;
    private final AttractionRepository attractionRepository;
    private final SurveyRepository surveyRepository;

    public ExportController(MeasurementRepository measurementRepository,
                            UserRepository userRepository,
                            AttractionRepository attractionRepository,
                            SurveyRepository surveyRepository) {
        this.measurementRepository = measurementRepository;
        this.userRepository = userRepository;
        this.attractionRepository = attractionRepository;
        this.surveyRepository = surveyRepository;
    }

    // 1. Zwykły Endpoint JSON (Do tworzenia wykresów w aplikacjach webowych i bibliotek JS)
    @GetMapping("/measurements/json")
    public ResponseEntity<List<Measurement>> exportJson() {
        return ResponseEntity.ok(measurementRepository.findAll());
    }

    // 2. Endpoint CSV dla Google Sheets (Z inteligentną podmianą UUID na nazwy!)
    @GetMapping(value = "/measurements/csv", produces = "text/csv; charset=utf-8")
    public ResponseEntity<String> exportCsv() {
        List<Measurement> measurements = measurementRepository.findAll();
        
        // Pobieramy słowniki, aby nie eksportować brzydkich UUID
        Map<java.util.UUID, String> userMap = userRepository.findAll().stream()
                .collect(Collectors.toMap(User::getId, User::getUsername));
                
        Map<java.util.UUID, String> attractionMap = attractionRepository.findAll().stream()
                .collect(Collectors.toMap(Attraction::getId, Attraction::getName));

        StringBuilder csvBuilder = new StringBuilder();
        // Nagłówki CSV
        csvBuilder.append("ID_Pomiaru,Pracownik,Atrakcja,Czas_Rozpoczecia,Czas_Zakonczenia,Laczny_Czas_W_Sekundach,Status_Synchronizacji\n");

        for (Measurement m : measurements) {
            String workerName = userMap.getOrDefault(m.getOperatorId(), "Nieznany (" + m.getOperatorId() + ")");
            String attractionName = attractionMap.getOrDefault(m.getAttractionId(), "Nieznana (" + m.getAttractionId() + ")");
            
            String startTime = m.getStartTime() != null ? m.getStartTime().toString() : "";
            String stopTime = m.getStopTime() != null ? m.getStopTime().toString() : "";
            String duration = m.getTotalDurationSeconds() != null ? m.getTotalDurationSeconds().toString() : "";

            csvBuilder.append(String.format("%s,%s,%s,%s,%s,%s,%s\n",
                    m.getId(),
                    workerName,
                    attractionName,
                    startTime,
                    stopTime,
                    duration,
                    m.getSyncStatus()
            ));
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"measurements_export.csv\"")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(csvBuilder.toString());
    }

    // 3. Endpoint administracyjny: Czyszczenie bazy pomiarów
    @org.springframework.web.bind.annotation.DeleteMapping("/measurements/clear")
    public ResponseEntity<Map<String, String>> clearMeasurements() {
        measurementRepository.deleteAll();
        return ResponseEntity.ok(Map.of("message", "Wszystkie pomiary zostały pomyślnie usunięte z bazy danych."));
    }

    // 4. Endpoint dla Mapy HTML (Dashboard serwera)
    @GetMapping("/attractions/json")
    public ResponseEntity<List<Map<String, Object>>> getAttractionsJson() {
        return ResponseEntity.ok(attractionRepository.findAll().stream().map(attr -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", attr.getId());
            map.put("name", attr.getName());
            map.put("latitude", attr.getLatitude());
            map.put("longitude", attr.getLongitude());
            map.put("radius", attr.getRadius());
            map.put("isActive", attr.getIsActive());
            return map;
        }).collect(java.util.stream.Collectors.toList()));
    }

    // 5. Endpoint dla Ankiet (Dashboard serwera)
    @GetMapping("/surveys/json")
    public ResponseEntity<List<Map<String, Object>>> getSurveysJson() {
        return ResponseEntity.ok(surveyRepository.findAll().stream().map(s -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", s.getId());
            
            String operatorName = userRepository.findById(s.getOperatorId())
                .map(User::getUsername)
                .orElse("Nieznany");
            
            map.put("operatorName", operatorName);
            map.put("createdAt", s.getCreatedAt());
            map.put("rating", s.getRating());
            map.put("strengths", s.getStrengths());
            map.put("improvements", s.getImprovements());
            map.put("recommendRating", s.getRecommendRating());
            map.put("source", s.getSource());
            map.put("sourceOther", s.getSourceOther());
            map.put("notes", s.getNotes());
            return map;
        }).collect(Collectors.toList()));
    }

    @GetMapping("/surveys/csv")
    public ResponseEntity<String> getSurveysCsv() {
        StringBuilder csv = new StringBuilder("ID,Pracownik,Data,Ocena Ogólna,Mocne Strony,Do Poprawy,Skłonność do polecenia,Źródło,Inne Źródło,Uwagi\n");
        surveyRepository.findAll().forEach(s -> {
            String operatorName = userRepository.findById(s.getOperatorId())
                .map(User::getUsername).orElse("Nieznany");
                
            csv.append(String.format("%s,%s,%s,%d,\"%s\",\"%s\",%d,\"%s\",\"%s\",\"%s\"\n",
                s.getId(),
                operatorName,
                s.getCreatedAt(),
                s.getRating(),
                (s.getStrengths() != null ? s.getStrengths().replace("\"", "\"\"") : ""),
                (s.getImprovements() != null ? s.getImprovements().replace("\"", "\"\"") : ""),
                s.getRecommendRating(),
                (s.getSource() != null ? s.getSource().replace("\"", "\"\"") : ""),
                (s.getSourceOther() != null ? s.getSourceOther().replace("\"", "\"\"") : ""),
                (s.getNotes() != null ? s.getNotes().replace("\"", "\"\"") : "")
            ));
        });

        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.add(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=ankiety.csv");
        headers.add(org.springframework.http.HttpHeaders.CONTENT_TYPE, "text/csv; charset=UTF-8");

        return new ResponseEntity<>('\uFEFF' + csv.toString(), headers, org.springframework.http.HttpStatus.OK);
    }

    // 6. Automatyczne przekierowanie na mapę
    @GetMapping("/")
    public void redirect(jakarta.servlet.http.HttpServletResponse response) throws java.io.IOException {
        response.sendRedirect("/mapa.html");
    }
}
