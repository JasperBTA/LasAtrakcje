package com.las.timeapp.controller;

import com.las.timeapp.dto.SyncRequest;
import com.las.timeapp.service.SyncService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final SyncService syncService;
    private final com.las.timeapp.repository.UserRepository userRepository;

    public SyncController(SyncService syncService, com.las.timeapp.repository.UserRepository userRepository) {
        this.syncService = syncService;
        this.userRepository = userRepository;
    }

    @PostMapping("/measurements")
    public ResponseEntity<Map<String, Object>> syncMeasurements(@RequestBody SyncRequest request) {
        if (request == null || request.getMeasurements() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Empty payload"));
        }

        int syncedCount = syncService.processSync(request).size();
        return ResponseEntity.ok(Map.of(
            "status", "SUCCESS",
            "syncedCount", syncedCount
        ));
    }

    @GetMapping("/users")
    public ResponseEntity<?> syncUsers() {
        // Zwracamy wszystkich użytkowników, aby aplikacja mogła sobie stworzyć lustro do logowania offline.
        java.util.List<Map<String, Object>> users = userRepository.findAll().stream()
            .map(u -> Map.<String, Object>of(
                "id", u.getId(),
                "username", u.getUsername(),
                "passwordHash", u.getPasswordHash(),
                "pinHash", u.getPinHash() != null ? u.getPinHash() : "",
                "role", u.getRole()
            ))
            .toList();
        return ResponseEntity.ok(users);
    }
}
