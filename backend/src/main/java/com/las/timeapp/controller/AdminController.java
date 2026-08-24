package com.las.timeapp.controller;

import com.las.timeapp.dto.AttractionCreateRequest;
import com.las.timeapp.dto.UserCreateRequest;
import com.las.timeapp.dto.UserUpdateRequest;
import com.las.timeapp.model.Attraction;
import com.las.timeapp.model.User;
import com.las.timeapp.repository.AttractionRepository;
import com.las.timeapp.repository.UserRepository;
import com.las.timeapp.repository.MeasurementRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import com.las.timeapp.dto.AttractionUpdateRequest;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserRepository userRepository;
    private final AttractionRepository attractionRepository;
    private final MeasurementRepository measurementRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminController(UserRepository userRepository, 
                           AttractionRepository attractionRepository, 
                           MeasurementRepository measurementRepository,
                           PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.attractionRepository = attractionRepository;
        this.measurementRepository = measurementRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody UserCreateRequest request) {
        Optional<User> existing = userRepository.findByUsername(request.getUsername());
        if (existing.isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "User already exists"));
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        
        if (request.getPin() != null && !request.getPin().trim().isEmpty()) {
            user.setPinHash(passwordEncoder.encode(request.getPin().trim()));
        }

        user.setRole(request.getRole() != null ? request.getRole().toUpperCase() : "WORKER");
        user.setCreatedAt(OffsetDateTime.now());

        userRepository.save(user);
        return ResponseEntity.ok(Map.of("status", "success", "userId", user.getId()));
    }

    @PostMapping("/attractions")
    public ResponseEntity<?> createAttraction(@RequestBody AttractionCreateRequest request) {
        Attraction attraction = new Attraction();
        attraction.setName(request.getName());
        attraction.setLatitude(request.getLatitude());
        attraction.setLongitude(request.getLongitude());
        attraction.setRadius(request.getRadius() != null ? request.getRadius() : 10.0);
        attraction.setIsActive(true);
        attraction.setCreatedAt(OffsetDateTime.now());

        attractionRepository.save(attraction);
        return ResponseEntity.ok(Map.of("status", "success", "attractionId", attraction.getId()));
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable UUID id) {
        Optional<User> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        User user = userOpt.get();
        if ("admin".equalsIgnoreCase(user.getUsername()) || "ADMIN".equalsIgnoreCase(user.getRole())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Cannot delete an administrator account"));
        }
        
        userRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable UUID id, @RequestBody UserUpdateRequest request) {
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        User user = opt.get();
        if (request.getPassword() != null && !request.getPassword().trim().isEmpty()) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword().trim()));
        }
        if (request.getPin() != null && !request.getPin().trim().isEmpty()) {
            user.setPinHash(passwordEncoder.encode(request.getPin().trim()));
        }
        if (request.getRole() != null && !request.getRole().trim().isEmpty()) {
            user.setRole(request.getRole().trim().toUpperCase());
        }
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    @PutMapping("/attractions/{id}")
    public ResponseEntity<?> updateAttraction(@PathVariable UUID id, @RequestBody AttractionUpdateRequest request) {
        Optional<Attraction> opt = attractionRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Attraction attraction = opt.get();
        if (request.getName() != null) attraction.setName(request.getName());
        if (request.getRadius() != null) attraction.setRadius(request.getRadius());
        if (request.getIsActive() != null) attraction.setIsActive(request.getIsActive());
        if (request.getLatitude() != null) attraction.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) attraction.setLongitude(request.getLongitude());

        attractionRepository.save(attraction);
        return ResponseEntity.ok(Map.of("status", "success"));
    }
    @DeleteMapping("/attractions/{id}")
    public ResponseEntity<?> deleteAttraction(@PathVariable UUID id) {
        if (!attractionRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        attractionRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    @DeleteMapping("/measurements/{id}")
    public ResponseEntity<?> deleteMeasurement(@PathVariable UUID id) {
        if (!measurementRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        measurementRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "success"));
    }
}
