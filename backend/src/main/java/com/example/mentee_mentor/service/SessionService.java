package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.booking.BookingResponse;
import com.example.mentee_mentor.dto.session.SessionRequest;
import com.example.mentee_mentor.dto.session.SessionResponse;
import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.model.Session;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.BookingRepository;
import com.example.mentee_mentor.repository.SessionRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SessionService {

    private final SessionRepository sessionRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    @Transactional
    public SessionResponse startSession(Long mentorId, SessionRequest request) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + request.getBookingId()));

        // Verify mentor owns this booking's schedule
        if (!booking.getSchedule().getMentor().getId().equals(mentorId)) {
            throw new BadRequestException("You don't have permission to start this session");
        }

        User mentee = booking.getMentee();

        // Check if session already exists
        Optional<Session> existing = sessionRepository.findByBookingId(booking.getId());
        if (existing.isPresent()) {
            throw new BadRequestException("Session already exists for this booking");
        }

        // Check booking status
        if (booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new BadRequestException("Can only start sessions for confirmed bookings");
        }

        Session session = Session.builder()
                .booking(booking)
                .mentor(booking.getSchedule().getMentor())
                .mentee(mentee)
                .startedAt(LocalDateTime.now())
                .status(Session.SessionStatus.IN_PROGRESS)
                .notes(request.getNotes())
                .autoStarted(false)
                .build();

        Session saved = sessionRepository.save(session);
        return SessionResponse.fromEntity(saved);
    }

    @Transactional
    public SessionResponse endSession(Long mentorId, Long sessionId, String notes) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id: " + sessionId));

        // Verify mentor owns this session
        if (!session.getMentor().getId().equals(mentorId)) {
            throw new BadRequestException("You don't have permission to end this session");
        }

        if (session.getStatus() == Session.SessionStatus.COMPLETED || session.getStatus() == Session.SessionStatus.CANCELLED) {
            throw new BadRequestException("Session is already " + session.getStatus());
        }

        session.setEndedAt(LocalDateTime.now());
        session.setStatus(Session.SessionStatus.COMPLETED);
        if (notes != null) {
            session.setNotes(notes);
        }

        Session saved = sessionRepository.save(session);
        return SessionResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public SessionResponse getSessionById(Long sessionId) {
        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id: " + sessionId));
        return SessionResponse.fromEntity(session);
    }

    @Transactional(readOnly = true)
    public Page<SessionResponse> getMySessions(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        List<Session> sessions;
        if (user.getRole().equals(User.UserRole.MENTOR)) {
            sessions = sessionRepository.findByMentor(user);
        } else {
            sessions = sessionRepository.findByMentee(user);
        }

        return new org.springframework.data.domain.PageImpl<>(
                sessions.stream().map(SessionResponse::fromEntity).collect(Collectors.toList()),
                pageable,
                sessions.size()
        );
    }
}