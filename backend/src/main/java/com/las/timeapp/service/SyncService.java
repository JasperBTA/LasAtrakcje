package com.las.timeapp.service;

import com.las.timeapp.dto.MeasurementSyncDto;
import com.las.timeapp.dto.SyncRequest;
import com.las.timeapp.model.Measurement;
import com.las.timeapp.repository.MeasurementRepository;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SyncService {

    private final MeasurementRepository measurementRepository;
    private final ModelMapper modelMapper;

    public SyncService(MeasurementRepository measurementRepository, ModelMapper modelMapper) {
        this.measurementRepository = measurementRepository;
        this.modelMapper = modelMapper;
    }

    @Transactional
    public List<Measurement> processSync(SyncRequest request) {
        List<Measurement> savedMeasurements = new ArrayList<>();

        // Batch idempotency check
        Set<UUID> incomingIds = request.getMeasurements().stream()
                .map(MeasurementSyncDto::getId)
                .collect(Collectors.toSet());
        List<Measurement> existing = measurementRepository.findAllById(incomingIds);
        Set<UUID> existingIds = existing.stream().map(Measurement::getId).collect(Collectors.toSet());

        for (MeasurementSyncDto dto : request.getMeasurements()) {
            if (existingIds.contains(dto.getId())) {
                continue; // Skip already synced measurements (Idempotency Key hit)
            }

            Measurement measurement = modelMapper.map(dto, Measurement.class);

            // Calculate duration if not provided or to ensure correctness
            Integer duration = calculateDuration(dto.getStartTime(), dto.getStopTime());
            measurement.setTotalDurationSeconds(dto.getTotalDurationSeconds() != null ? dto.getTotalDurationSeconds() : duration);
            
            measurement.setSyncStatus("SYNCED");
            measurement.setCreatedAt(OffsetDateTime.now());

            savedMeasurements.add(measurementRepository.save(measurement));
        }
        return savedMeasurements;
    }

    public Integer calculateDuration(OffsetDateTime start, OffsetDateTime stop) {
        if (start == null || stop == null) {
            return null;
        }
        return (int) Duration.between(start, stop).getSeconds();
    }
}
