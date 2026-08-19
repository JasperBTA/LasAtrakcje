package com.las.timeapp.repository;

import com.las.timeapp.model.Attraction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AttractionRepository extends JpaRepository<Attraction, UUID> {
    List<Attraction> findByIsActiveTrue();
}
