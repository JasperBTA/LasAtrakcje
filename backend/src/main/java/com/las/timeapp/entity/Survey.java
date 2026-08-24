package com.las.timeapp.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "surveys")
public class Survey {

    @Id
    private String id;

    @Column(name = "operator_id")
    private Long operatorId;

    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @Column(name = "rating")
    private Integer rating;

    @Column(name = "strengths", length = 1000)
    private String strengths;

    @Column(name = "improvements", length = 1000)
    private String improvements;

    @Column(name = "recommend_rating")
    private Integer recommendRating;

    @Column(name = "source")
    private String source;

    @Column(name = "source_other")
    private String sourceOther;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "sync_status")
    private String syncStatus;

    public Survey() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getStrengths() { return strengths; }
    public void setStrengths(String strengths) { this.strengths = strengths; }

    public String getImprovements() { return improvements; }
    public void setImprovements(String improvements) { this.improvements = improvements; }

    public Integer getRecommendRating() { return recommendRating; }
    public void setRecommendRating(Integer recommendRating) { this.recommendRating = recommendRating; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getSourceOther() { return sourceOther; }
    public void setSourceOther(String sourceOther) { this.sourceOther = sourceOther; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getSyncStatus() { return syncStatus; }
    public void setSyncStatus(String syncStatus) { this.syncStatus = syncStatus; }
}
