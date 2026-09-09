package com.example.mentee_mentor.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "mentor_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", unique = true, nullable = false)
    private User user;

    @Column(name = "full_name", nullable = false, length = 255)
    private String fullName;

    @Column(name = "avatar", length = 500)
    private String avatar;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "school", length = 255)
    private String school;

    @Column(name = "degree", length = 255)
    private String degree;

    @Column(name = "years_exp")
    private Integer yearsExp;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToMany
    @JoinTable(
            name = "mentor_topic_expertise",
            joinColumns = @JoinColumn(name = "mentor_profile_id"),
            inverseJoinColumns = @JoinColumn(name = "topic_id")
    )
    private Set<Topic> expertise = new HashSet<>();
}