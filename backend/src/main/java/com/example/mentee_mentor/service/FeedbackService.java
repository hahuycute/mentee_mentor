package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.feedback.FeedbackRequest;
import com.example.mentee_mentor.dto.feedback.FeedbackResponse;
import com.example.mentee_mentor.model.Feedback;
import com.example.mentee_mentor.model.Session;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.FeedbackRepository;
import com.example.mentee_mentor.repository.SessionRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final SessionRepository sessionRepository;
    private final UserRepository userRepository;

    @Transactional
    public FeedbackResponse createFeedback(Long menteeId, FeedbackRequest request) {
        User mentee = userRepository.findById(menteeId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + menteeId));

        Session session = sessionRepository.findById(request.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with id: " + request.getSessionId()));

        // Verify mentee owns this session
        if (!session.getMentee().getId().equals(menteeId)) {
            throw new BadRequestException("You don't have permission to give feedback for this session");
        }

        // Check session status
        if (session.getStatus() != Session.SessionStatus.COMPLETED) {
            throw new BadRequestException("Can only give feedback for completed sessions");
        }

        // Check if feedback already exists
        if (feedbackRepository.findBySession(session).isPresent()) {
            throw new BadRequestException("Feedback already exists for this session");
        }

        Feedback feedback = Feedback.builder()
                .session(session)
                .mentor(session.getMentor())
                .mentee(mentee)
                .rating(request.getRating())
                .comment(request.getComment())
                .build();

        Feedback saved = feedbackRepository.save(feedback);
        return FeedbackResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public FeedbackResponse getFeedbackById(Long feedbackId) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new ResourceNotFoundException("Feedback not found with id: " + feedbackId));
        return FeedbackResponse.fromEntity(feedback);
    }

    @Transactional(readOnly = true)
    public Page<FeedbackResponse> getFeedbacksByMentor(Long mentorId, Pageable pageable) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));

        List<Feedback> feedbacks = feedbackRepository.findByMentor(mentor);

        return new org.springframework.data.domain.PageImpl<>(
                feedbacks.stream().map(FeedbackResponse::fromEntity).collect(Collectors.toList()),
                pageable,
                feedbacks.size()
        );
    }

    @Transactional(readOnly = true)
    public Page<FeedbackResponse> getMyFeedbacks(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        List<Feedback> feedbacks;
        if (user.getRole().equals(User.UserRole.MENTOR)) {
            feedbacks = feedbackRepository.findByMentor(user);
        } else {
            feedbacks = feedbackRepository.findByMentee(user);
        }

        return new org.springframework.data.domain.PageImpl<>(
                feedbacks.stream().map(FeedbackResponse::fromEntity).collect(Collectors.toList()),
                pageable,
                feedbacks.size()
        );
    }

    @Transactional(readOnly = true)
    public double getAverageRatingByMentor(Long mentorId) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));

        List<Feedback> feedbacks = feedbackRepository.findByMentor(mentor);
        if (feedbacks.isEmpty()) {
            return 0.0;
        }

        return feedbacks.stream()
                .mapToInt(Feedback::getRating)
                .average()
                .orElse(0.0);
    }
}