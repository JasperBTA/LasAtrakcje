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

@RestController
@RequestMapping("/api/export")
public class ExportController {

    private final MeasurementRepository measurementRepository;
    private final UserRepository userRepository;
    private final AttractionRepository attractionRepository;

    public ExportController(MeasurementRepository measurementRepository,
                            UserRepository userRepository,
                            AttractionRepository attractionRepository) {
        this.measurementRepository = measurementRepository;
        this.userRepository = userRepository;
        this.attractionRepository = attractionRepository;
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

    // 5. Automatyczne przekierowanie na mapę
    @GetMapping("/")
    public void redirect(jakarta.servlet.http.HttpServletResponse response) throws java.io.IOException {
        response.sendRedirect("/mapa.html");
    }
}
