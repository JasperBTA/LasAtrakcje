package com.las.timeapp.dto;

public class AttractionCreateRequest {
    private java.util.UUID id;
    private String name;
    private Double latitude;
    private Double longitude;
    private Double radius;

    public java.util.UUID getId() { return id; }
    public void setId(java.util.UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Double getRadius() { return radius; }
    public void setRadius(Double radius) { this.radius = radius; }
}
