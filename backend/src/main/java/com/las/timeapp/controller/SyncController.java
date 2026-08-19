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

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
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
}
