package com.las.timeapp.service;

import com.las.timeapp.model.GlobalSettings;
import com.las.timeapp.repository.GlobalSettingsRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class GlobalSettingsService {

    private final GlobalSettingsRepository repository;

    @Autowired
    public GlobalSettingsService(GlobalSettingsRepository repository) {
        this.repository = repository;
    }

    @PostConstruct
    public void initDefaultSettings() {
        if (!repository.existsById(1)) {
            // Domyślne łagodne ustawienia na start
            GlobalSettings defaults = new GlobalSettings(50, 4, 45, 10);
            repository.save(defaults);
        }
    }

    public GlobalSettings getSettings() {
        return repository.findById(1).orElseGet(() -> {
            GlobalSettings defaults = new GlobalSettings(50, 4, 45, 10);
            return repository.save(defaults);
        });
    }

    public GlobalSettings updateSettings(GlobalSettings newSettings) {
        GlobalSettings current = getSettings();
        current.setGpsAccuracyThreshold(newSettings.getGpsAccuracyThreshold());
        current.setEntryBufferSeconds(newSettings.getEntryBufferSeconds());
        current.setExitBufferSeconds(newSettings.getExitBufferSeconds());
        current.setHysteresisMargin(newSettings.getHysteresisMargin());
        return repository.save(current);
    }
}
