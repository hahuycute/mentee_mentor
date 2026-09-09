package com.example.mentee_mentor.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "sessions", uniqueConstraints = @UniqueConstraint(columnNames = "booking_id"))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Session {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", unique = true, nullable = false)
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mentor_id", nullable = false)
    private User mentor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mentee_id", nullable = false)
    private User mentee;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SessionStatus status = SessionStatus.SCHEDULED;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "auto_started", nullable = false)
    private Boolean autoStarted = false;

    @Column(name = "auto_ended", nullable = false)
    private Boolean autoEnded = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToOne(mappedBy = "session", cascade = CascadeType.ALL, orphanRemoval = true)
    private Feedback feedback;

    public enum SessionStatus {
        SCHEDULED,
        IN_PROGRESS,
        COMPLETED,
        CANCELLED
    }
}