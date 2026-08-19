package com.las.timeapp.controller;

import com.las.timeapp.model.Attraction;
import com.las.timeapp.repository.AttractionRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/attractions")
public class AttractionController {

    private final AttractionRepository attractionRepository;

    public AttractionController(AttractionRepository attractionRepository) {
        this.attractionRepository = attractionRepository;
    }

    @GetMapping
    public ResponseEntity<List<Attraction>> getActiveAttractions() {
        return ResponseEntity.ok(attractionRepository.findByIsActiveTrue());
    }

    @PostMapping("/sync")
    public ResponseEntity<?> syncAttractions(@RequestBody Map<String, List<Map<String, Object>>> body) {
        List<Map<String, Object>> attractions = body.get("attractions");
        if (attractions != null) {
            for (Map<String, Object> dto : attractions) {
                String idStr = (String) dto.get("id");
                try {
                    UUID id = UUID.fromString(idStr);
                    attractionRepository.findById(id).ifPresent(attr -> {
                        if (dto.get("latitude") != null) {
                            attr.setLatitude(((Number) dto.get("latitude")).doubleValue());
                        }
                        if (dto.get("longitude") != null) {
                            attr.setLongitude(((Number) dto.get("longitude")).doubleValue());
                        }
                        attractionRepository.save(attr);
                        System.out.println("Zaktualizowano GPS (offline sync) dla: " + attr.getName());
                    });
                } catch (Exception e) {
                    System.out.println("Błąd aktualizacji GPS: " + e.getMessage());
                }
            }
        }
        return ResponseEntity.ok(Map.of("status", "success"));
    }
}
