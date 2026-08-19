package com.las.timeapp.dto;

import java.util.List;

public class SyncRequest {
    private List<MeasurementSyncDto> measurements;

    public List<MeasurementSyncDto> getMeasurements() { return measurements; }
    public void setMeasurements(List<MeasurementSyncDto> measurements) { this.measurements = measurements; }
}
