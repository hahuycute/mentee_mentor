package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.MenteeProfile;
import com.example.mentee_mentor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MenteeProfileRepository extends JpaRepository<MenteeProfile, Long> {

    Optional<MenteeProfile> findByUser(User user);

    Optional<MenteeProfile> findByUserId(Long userId);
}