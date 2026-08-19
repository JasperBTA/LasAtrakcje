package com.las.timeapp.service;

import org.junit.jupiter.api.Test;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.*;

class SyncServiceTest {

    private final SyncService syncService = new SyncService(null, null);

    @Test
    void shouldCalculateDurationCorrectly() {
        OffsetDateTime start = OffsetDateTime.of(2026, 8, 18, 10, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime stop = OffsetDateTime.of(2026, 8, 18, 10, 5, 30, 0, ZoneOffset.UTC);

        Integer duration = syncService.calculateDuration(start, stop);

        assertNotNull(duration);
        assertEquals(330, duration); // 5 minutes * 60 + 30 seconds = 330 seconds
    }

    @Test
    void shouldReturnNullIfStartOrStopIsNull() {
        OffsetDateTime time = OffsetDateTime.of(2026, 8, 18, 10, 0, 0, 0, ZoneOffset.UTC);
        
        assertNull(syncService.calculateDuration(null, time));
        assertNull(syncService.calculateDuration(time, null));
        assertNull(syncService.calculateDuration(null, null));
    }
}
