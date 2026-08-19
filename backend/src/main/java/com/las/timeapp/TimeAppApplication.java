package com.las.timeapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.las.timeapp.repository.UserRepository;
import com.las.timeapp.repository.AttractionRepository;
import com.las.timeapp.model.User;
import com.las.timeapp.model.Attraction;
import java.util.Arrays;
import java.util.List;

@SpringBootApplication
public class TimeAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(TimeAppApplication.class, args);
    }

    @Bean
    public CommandLineRunner dataLoader(UserRepository userRepository, AttractionRepository attractionRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                User testUser = new User();
                testUser.setUsername("test");
                testUser.setPasswordHash(passwordEncoder.encode("test"));
                testUser.setCreatedAt(java.time.OffsetDateTime.now());
                testUser.setRole("WORKER");
                userRepository.save(testUser);

                User adminUser = new User();
                adminUser.setUsername("admin");
                adminUser.setPasswordHash(passwordEncoder.encode("admin"));
                adminUser.setCreatedAt(java.time.OffsetDateTime.now());
                adminUser.setRole("ADMIN");
                userRepository.save(adminUser);

                System.out.println("Utworzono domyślnych użytkowników: test/test (WORKER) oraz admin/admin (ADMIN)");
            }
            if (attractionRepository.count() == 0) {
                List<String> names = Arrays.asList(
                    "LEŚNA SKOCZNIA", "POLANA JEŻA JERZEGO", "KORZENIOWY TUNEL", "KORZENIOWE HUŚTAWKI",
                    "PIEŃKOWA POLANA", "POLANA PAJĄKA STEFANA", "POLANA DOTYKU", "POLANA GLADIATORÓW",
                    "LEŚNA RÓWNOWAŻNIA", "KULA HULA", "POLANA PNIA", "POLANA DŹWIĘKU", "LEŚNY TOR PRZESZKÓD",
                    "DRZEWO ODKRYWCY", "LIŚCIASTA ŚCIANKA WSPINACZKOWA", "KOPIEC KRETA HILAREGO", "LEŚNA STRZELNICA",
                    "PROCE GULIWERA", "POLANA DRUGIEGO ŻYCIA", "LEŚNE ŁOWISKO", "POLANA ZAPACHU", "POLANA TARZANA",
                    "LEŚNA TYROLKA", "DZIKA POLANA", "MRÓWCZY LABIRYNT", "ŚCIANKA WSPINACZKOWA", "POLANA EMOCJI",
                    "WIEWIÓRCZE MIASTECZKO", "LISIE NORY", "POLANA ZABAW WODNYCH"
                );
                double lat = 50.000000;
                double lng = 20.000000;
                for (String name : names) {
                    Attraction attr = new Attraction();
                    attr.setName(name);
                    attr.setLatitude(lat);
                    attr.setLongitude(lng);
                    attr.setRadius(10.0);
                    attr.setIsActive(true);
                    attr.setCreatedAt(java.time.OffsetDateTime.now());
                    attractionRepository.save(attr);
                    lat += 0.000045; // ok. 5 metrów różnicy na siatce GPS
                }
                System.out.println("Utworzono " + names.size() + " startowych atrakcji leśnych!");
            }
        };
    }
}
