package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Session;
import com.example.mentee_mentor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SessionRepository extends JpaRepository<Session, Long> {

    List<Session> findByMentor(User mentor);

    List<Session> findByMentee(User mentee);

    Optional<Session> findByBookingId(Long bookingId);

    List<Session> findByStatus(Session.SessionStatus status);
}