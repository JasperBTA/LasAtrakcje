package com.las.timeapp.repository;

import com.las.timeapp.model.Measurement;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface MeasurementRepository extends JpaRepository<Measurement, UUID> {
}
