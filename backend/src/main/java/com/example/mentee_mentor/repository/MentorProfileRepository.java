package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.MentorProfile;
import com.example.mentee_mentor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MentorProfileRepository extends JpaRepository<MentorProfile, Long> {

    Optional<MentorProfile> findByUser(User user);

    Optional<MentorProfile> findByUserId(Long userId);
}