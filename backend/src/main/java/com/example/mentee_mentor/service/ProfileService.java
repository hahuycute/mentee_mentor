package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.profile.MenteeProfileResponse;
import com.example.mentee_mentor.dto.profile.MentorProfileResponse;
import com.example.mentee_mentor.dto.profile.MentorProfileRequest;
import com.example.mentee_mentor.dto.profile.ProfileStatsResponse;
import com.example.mentee_mentor.model.MenteeProfile;
import com.example.mentee_mentor.model.MentorProfile;
import com.example.mentee_mentor.model.Topic;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.MenteeProfileRepository;
import com.example.mentee_mentor.repository.MentorProfileRepository;
import com.example.mentee_mentor.repository.TopicRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserRepository userRepository;
    private final MentorProfileRepository mentorProfileRepository;
    private final MenteeProfileRepository menteeProfileRepository;
    private final TopicRepository topicRepository;

    @Transactional(readOnly = true)
    public MentorProfileResponse getMentorProfile(Long userId) {
        Optional<MentorProfile> profileOpt = mentorProfileRepository.findByUserId(userId);
        return profileOpt.map(MentorProfileResponse::fromEntity).orElse(null);
    }

    @Transactional(readOnly = true)
    public MenteeProfileResponse getMenteeProfile(Long userId) {
        Optional<MenteeProfile> profileOpt = menteeProfileRepository.findByUserId(userId);
        return profileOpt.map(MenteeProfileResponse::fromEntity).orElse(null);
    }

    @Transactional(readOnly = true)
    public ProfileStatsResponse getProfileStats(Long userId) {
        // TODO: Implement actual stats calculation
        return ProfileStatsResponse.builder()
                .completedSessions(0L)
                .averageRating(0.0)
                .totalReviews(0L)
                .build();
    }

    @Transactional
    public MentorProfileResponse createMentorProfile(Long userId, MentorProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        if (mentorProfileRepository.findByUserId(userId).isPresent()) {
            throw new BadRequestException("Mentor profile already exists for this user");
        }

        Set<Topic> expertise = request.getExpertiseIds() != null ?
                request.getExpertiseIds().stream()
                        .map(id -> topicRepository.findById(id)
                                .orElseThrow(() -> new ResourceNotFoundException("Topic not found with id: " + id)))
                        .collect(Collectors.toSet()) : Set.of();

        MentorProfile profile = MentorProfile.builder()
                .user(user)
                .fullName(request.getFullName())
                .avatar(request.getAvatar())
                .phoneNumber(request.getPhoneNumber())
                .school(request.getSchool())
                .degree(request.getDegree())
                .yearsExp(request.getYearsExp())
                .bio(request.getBio())
                .expertise(expertise)
                .build();

        MentorProfile saved = mentorProfileRepository.save(profile);
        return MentorProfileResponse.fromEntity(saved);
    }

    @Transactional
    public MentorProfileResponse updateMentorProfile(Long userId, MentorProfileRequest request) {
        MentorProfile profile = mentorProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Mentor profile not found for user id: " + userId));

        if (request.getExpertiseIds() != null) {
            Set<Topic> expertise = request.getExpertiseIds().stream()
                    .map(id -> topicRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException("Topic not found with id: " + id)))
                    .collect(Collectors.toSet());
            profile.setExpertise(expertise);
        }

        if (request.getFullName() != null) profile.setFullName(request.getFullName());
        if (request.getAvatar() != null) profile.setAvatar(request.getAvatar());
        if (request.getPhoneNumber() != null) profile.setPhoneNumber(request.getPhoneNumber());
        if (request.getSchool() != null) profile.setSchool(request.getSchool());
        if (request.getDegree() != null) profile.setDegree(request.getDegree());
        if (request.getYearsExp() != null) profile.setYearsExp(request.getYearsExp());
        if (request.getBio() != null) profile.setBio(request.getBio());

        MentorProfile saved = mentorProfileRepository.save(profile);
        return MentorProfileResponse.fromEntity(saved);
    }
}