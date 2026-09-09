package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Feedback;
import com.example.mentee_mentor.model.Session;
import com.example.mentee_mentor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    List<Feedback> findByMentor(User mentor);

    List<Feedback> findByMentee(User mentee);

    Optional<Feedback> findBySession(Session session);
}