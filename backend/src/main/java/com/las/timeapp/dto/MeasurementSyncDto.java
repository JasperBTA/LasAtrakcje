package com.las.timeapp.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public class MeasurementSyncDto {
    private UUID id;
    private UUID operatorId;
    private UUID attractionId;
    private OffsetDateTime startTime;
    private OffsetDateTime stopTime;
    private Integer totalDurationSeconds;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOperatorId() { return operatorId; }
    public void setOperatorId(UUID operatorId) { this.operatorId = operatorId; }
    public UUID getAttractionId() { return attractionId; }
    public void setAttractionId(UUID attractionId) { this.attractionId = attractionId; }
    public OffsetDateTime getStartTime() { return startTime; }
    public void setStartTime(OffsetDateTime startTime) { this.startTime = startTime; }
    public OffsetDateTime getStopTime() { return stopTime; }
    public void setStopTime(OffsetDateTime stopTime) { this.stopTime = stopTime; }
    public Integer getTotalDurationSeconds() { return totalDurationSeconds; }
    public void setTotalDurationSeconds(Integer totalDurationSeconds) { this.totalDurationSeconds = totalDurationSeconds; }
}
