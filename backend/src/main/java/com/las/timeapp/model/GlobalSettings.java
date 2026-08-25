package com.las.timeapp.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "global_settings")
public class GlobalSettings {
    @Id
    private Integer id = 1;

    private Integer gpsAccuracyThreshold;
    private Integer entryBufferSeconds;
    private Integer exitBufferSeconds;
    private Integer hysteresisMargin;

    public GlobalSettings() {}

    public GlobalSettings(Integer gpsAccuracyThreshold, Integer entryBufferSeconds, Integer exitBufferSeconds, Integer hysteresisMargin) {
        this.gpsAccuracyThreshold = gpsAccuracyThreshold;
        this.entryBufferSeconds = entryBufferSeconds;
        this.exitBufferSeconds = exitBufferSeconds;
        this.hysteresisMargin = hysteresisMargin;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getGpsAccuracyThreshold() {
        return gpsAccuracyThreshold;
    }

    public void setGpsAccuracyThreshold(Integer gpsAccuracyThreshold) {
        this.gpsAccuracyThreshold = gpsAccuracyThreshold;
    }

    public Integer getEntryBufferSeconds() {
        return entryBufferSeconds;
    }

    public void setEntryBufferSeconds(Integer entryBufferSeconds) {
        this.entryBufferSeconds = entryBufferSeconds;
    }

    public Integer getExitBufferSeconds() {
        return exitBufferSeconds;
    }

    public void setExitBufferSeconds(Integer exitBufferSeconds) {
        this.exitBufferSeconds = exitBufferSeconds;
    }

    public Integer getHysteresisMargin() {
        return hysteresisMargin;
    }

    public void setHysteresisMargin(Integer hysteresisMargin) {
        this.hysteresisMargin = hysteresisMargin;
    }
}
