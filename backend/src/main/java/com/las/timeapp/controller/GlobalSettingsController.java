package com.las.timeapp.controller;

import com.las.timeapp.model.GlobalSettings;
import com.las.timeapp.service.GlobalSettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/settings")
public class GlobalSettingsController {

    private final GlobalSettingsService service;

    @Autowired
    public GlobalSettingsController(GlobalSettingsService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<GlobalSettings> getSettings() {
        return ResponseEntity.ok(service.getSettings());
    }

    @PostMapping
    public ResponseEntity<GlobalSettings> updateSettings(@RequestBody GlobalSettings newSettings) {
        return ResponseEntity.ok(service.updateSettings(newSettings));
    }
}
