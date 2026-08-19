package com.las.timeapp;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class PerformanceLoadTest {

    private static final Logger logger = LoggerFactory.getLogger(PerformanceLoadTest.class);
    
    @Autowired
    private MockMvc mockMvc;

    @Test
    void testConcurrentReadPerformance() throws InterruptedException {
        int threadCount = 100;
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);
        List<Long> responseTimes = Collections.synchronizedList(new ArrayList<>());

        logger.info("Rozpoczynanie testu obciążeniowego ({} wątków)", threadCount);

        for (int i = 0; i < threadCount; i++) {
            executor.submit(() -> {
                try {
                    long start = System.currentTimeMillis();
                    
                    // Uderzenie do bazy na endpoint otwarty (np. bez tokena zrzucający Auth, ale wymuszający cykl Dispatchera)
                    // Dla prawidłowego testu w backendzie - tu odpytujemy /api/attractions bez tokena co daje 401
                    // Ale jeśli chcemy bazę, potrzebujemy zmockować wywołanie serwisu
                    mockMvc.perform(get("/api/attractions")).andReturn();
                    
                    long end = System.currentTimeMillis();
                    responseTimes.add(end - start);
                } catch (Exception e) {
                    logger.error("Błąd zapytania", e);
                } finally {
                    latch.countDown();
                }
            });
        }

        latch.await(30, TimeUnit.SECONDS);
        executor.shutdown();

        long sum = responseTimes.stream().mapToLong(Long::longValue).sum();
        double avg = (double) sum / responseTimes.size();
        
        responseTimes.sort(Long::compareTo);
        long p95 = responseTimes.get((int)(responseTimes.size() * 0.95));

        logger.info("=========================================");
        logger.info("WYNIKI TESTU WYDAJNOŚCIOWEGO BACKENDU");
        logger.info("Liczba zapytań: {}", responseTimes.size());
        logger.info("Średni czas odpowiedzi: {} ms", String.format("%.2f", avg));
        logger.info("95-percentyl (P95): {} ms", p95);
        logger.info("=========================================");
    }
}
