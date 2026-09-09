package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.dashboard.*;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.model.*;
import com.example.mentee_mentor.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

import static java.util.Collections.emptySet;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final SessionRepository sessionRepository;
    private final PostRepository postRepository;
    private final LikeRepository likeRepository;
    private final FeedbackRepository feedbackRepository;
    private final MentorProfileRepository mentorProfileRepository;
    private final MenteeProfileRepository menteeProfileRepository;
    private final TopicRepository topicRepository;

    // ==================== ADMIN DASHBOARD ====================

    @Transactional(readOnly = true)
    public AdminDashboardResponse getAdminDashboard() {
        return AdminDashboardResponse.builder()
                .userStats(getUserStats())
                .bookingStats(getBookingStats())
                .sessionStats(getSessionStats())
                .postStats(getPostStats())
                .revenueStats(getRevenueStats())
                .systemHealth(getSystemHealth())
                .build();
    }

    private UserStatsResponse getUserStats() {
        List<User> allUsers = userRepository.findAll();
        long totalUsers = allUsers.size();
        long totalMentors = allUsers.stream().filter(u -> u.getRole() == User.UserRole.MENTOR).count();
        long totalMentees = allUsers.stream().filter(u -> u.getRole() == User.UserRole.MENTEE).count();
        long totalAdmins = allUsers.stream().filter(u -> u.getRole() == User.UserRole.ADMIN).count();
        long activeUsers = allUsers.stream().filter(User::getIsActive).count();
        long inactiveUsers = totalUsers - activeUsers;
        long verifiedUsers = allUsers.stream().filter(User::getIsEmailVerified).count();
        long unverifiedUsers = totalUsers - verifiedUsers;

        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        long newUsersThisMonth = allUsers.stream()
                .filter(u -> u.getCreatedAt() != null && u.getCreatedAt().isAfter(monthStart))
                .count();
        long activeUsersThisMonth = allUsers.stream()
                .filter(u -> u.getUpdatedAt() != null && u.getUpdatedAt().isAfter(monthStart))
                .count();

        return UserStatsResponse.builder()
                .totalUsers(totalUsers)
                .totalMentors(totalMentors)
                .totalMentees(totalMentees)
                .totalAdmins(totalAdmins)
                .newUsersThisMonth(newUsersThisMonth)
                .activeUsersThisMonth(activeUsersThisMonth)
                .inactiveUsers(inactiveUsers)
                .verifiedUsers(verifiedUsers)
                .unverifiedUsers(unverifiedUsers)
                .build();
    }

    private BookingStatsResponse getBookingStats() {
        List<Booking> allBookings = bookingRepository.findAll();
        long totalBookings = allBookings.size();
        long pendingBookings = allBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.PENDING).count();
        long confirmedBookings = allBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CONFIRMED).count();
        long cancelledBookings = allBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CANCELLED).count();
        long completedBookings = allBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED).count();

        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        long bookingsThisMonth = allBookings.stream()
                .filter(b -> b.getCreatedAt() != null && b.getCreatedAt().isAfter(monthStart))
                .count();

        long totalUsers = userRepository.findAll().size();
        double averageBookingsPerUser = totalUsers > 0 ? (double) totalBookings / totalUsers : 0.0;

        return BookingStatsResponse.builder()
                .totalBookings(totalBookings)
                .pendingBookings(pendingBookings)
                .confirmedBookings(confirmedBookings)
                .cancelledBookings(cancelledBookings)
                .completedBookings(completedBookings)
                .bookingsThisMonth(bookingsThisMonth)
                .averageBookingsPerUser(averageBookingsPerUser)
                .build();
    }

    private SessionStatsResponse getSessionStats() {
        List<Session> allSessions = sessionRepository.findAll();
        long totalSessions = allSessions.size();
        long scheduledSessions = allSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.SCHEDULED).count();
        long inProgressSessions = allSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.IN_PROGRESS).count();
        long completedSessions = allSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.COMPLETED).count();
        long cancelledSessions = allSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.CANCELLED).count();

        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        long sessionsThisMonth = allSessions.stream()
                .filter(s -> s.getCreatedAt() != null && s.getCreatedAt().isAfter(monthStart))
                .count();

        double averageDuration = allSessions.stream()
                .filter(s -> s.getStartedAt() != null && s.getEndedAt() != null)
                .mapToLong(s -> java.time.Duration.between(s.getStartedAt(), s.getEndedAt()).toMinutes())
                .average()
                .orElse(0.0);

        double completionRate = totalSessions > 0 ? (double) completedSessions / totalSessions * 100 : 0.0;

        return SessionStatsResponse.builder()
                .totalSessions(totalSessions)
                .scheduledSessions(scheduledSessions)
                .inProgressSessions(inProgressSessions)
                .completedSessions(completedSessions)
                .cancelledSessions(cancelledSessions)
                .sessionsThisMonth(sessionsThisMonth)
                .averageSessionDurationMinutes(averageDuration)
                .completionRate(completionRate)
                .build();
    }

    private PostStatsResponse getPostStats() {
        List<Post> allPosts = postRepository.findAll();
        long totalPosts = allPosts.size();
        long publishedPosts = allPosts.stream().filter(Post::getIsPublic).count();
        long draftPosts = totalPosts - publishedPosts;

        long totalLikes = allPosts.stream().mapToLong(p -> likeRepository.countByPost(p)).sum();
        long postsThisMonth = allPosts.stream()
                .filter(p -> p.getCreatedAt() != null && p.getCreatedAt().isAfter(LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0)))
                .count();

        double averageLikesPerPost = totalPosts > 0 ? (double) totalLikes / totalPosts : 0.0;
        double engagementRate = totalPosts > 0 ? (double) totalLikes / totalPosts * 100 : 0.0;

        return PostStatsResponse.builder()
                .totalPosts(totalPosts)
                .publishedPosts(publishedPosts)
                .draftPosts(draftPosts)
                .totalLikes(totalLikes)
                .totalComments(0L) // TODO: Add Comment entity
                .postsThisMonth(postsThisMonth)
                .averageLikesPerPost(averageLikesPerPost)
                .engagementRate(engagementRate)
                .build();
    }

    private RevenueStatsResponse getRevenueStats() {
        // TODO: Implement when payment system is added
        return RevenueStatsResponse.builder()
                .totalRevenue(0.0)
                .revenueThisMonth(0.0)
                .revenueLastMonth(0.0)
                .averageRevenuePerBooking(0.0)
                .totalPaidBookings(0L)
                .growthRatePercent(0.0)
                .build();
    }

    private SystemHealthResponse getSystemHealth() {
        // TODO: Implement actual health checks
        return SystemHealthResponse.builder()
                .databaseStatus("UP")
                .apiResponseTime("< 100ms")
                .activeConnections(0L)
                .errorRateLastHour(0L)
                .lastBackupTime(LocalDateTime.now().minusHours(1).toString())
                .build();
    }

    // ==================== MENTOR DASHBOARD ====================

    @Transactional(readOnly = true)
    public MentorDashboardResponse getMentorDashboard(Long mentorId) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("Mentor not found with id: " + mentorId));

        Optional<MentorProfile> profileOpt = mentorProfileRepository.findByUserId(mentorId);

        return MentorDashboardResponse.builder()
                .profileSummary(getMentorProfileSummary(mentor, profileOpt))
                .bookingStats(getMentorBookingStats(mentor))
                .sessionStats(getMentorSessionStats(mentor))
                .earnings(getMentorEarnings(mentor))
                .rating(getMentorRating(mentor))
                .upcoming(getMentorUpcoming(mentor))
                .build();
    }

    private MentorProfileSummaryResponse getMentorProfileSummary(User mentor, Optional<MentorProfile> profileOpt) {
        if (profileOpt.isEmpty()) {
            return MentorProfileSummaryResponse.builder()
                    .mentorId(mentor.getId())
                    .fullName(mentor.getFullName())
                    .avatar(mentor.getAvatar())
                    .yearsExp(0)
                    .school("")
                    .degree("")
                    .isProfileComplete(false)
                    .build();
        }

        MentorProfile profile = profileOpt.get();
        return MentorProfileSummaryResponse.builder()
                .mentorId(mentor.getId())
                .fullName(profile.getFullName())
                .avatar(profile.getAvatar())
                .yearsExp(profile.getYearsExp())
                .school(profile.getSchool())
                .degree(profile.getDegree())
                .isProfileComplete(profile.getFullName() != null && profile.getSchool() != null && profile.getDegree() != null)
                .build();
    }

    private MentorBookingStatsResponse getMentorBookingStats(User mentor) {
        List<Booking> mentorBookings = bookingRepository.findBySchedule_Mentor(mentor);
        long totalBookings = mentorBookings.size();
        long pendingBookings = mentorBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.PENDING).count();
        long confirmedBookings = mentorBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CONFIRMED).count();
        long completedBookings = mentorBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED).count();
        long cancelledBookings = mentorBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CANCELLED).count();

        LocalDateTime weekStart = LocalDateTime.now().minusDays(7);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);

        long bookingsThisWeek = mentorBookings.stream()
                .filter(b -> b.getCreatedAt() != null && b.getCreatedAt().isAfter(weekStart))
                .count();
        long bookingsThisMonth = mentorBookings.stream()
                .filter(b -> b.getCreatedAt() != null && b.getCreatedAt().isAfter(monthStart))
                .count();

        return MentorBookingStatsResponse.builder()
                .totalBookings(totalBookings)
                .pendingBookings(pendingBookings)
                .confirmedBookings(confirmedBookings)
                .completedBookings(completedBookings)
                .cancelledBookings(cancelledBookings)
                .bookingsThisWeek(bookingsThisWeek)
                .bookingsThisMonth(bookingsThisMonth)
                .build();
    }

    private MentorSessionStatsResponse getMentorSessionStats(User mentor) {
        List<Session> mentorSessions = sessionRepository.findByMentor(mentor);
        long totalSessions = mentorSessions.size();
        long scheduledSessions = mentorSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.SCHEDULED).count();
        long inProgressSessions = mentorSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.IN_PROGRESS).count();
        long completedSessions = mentorSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.COMPLETED).count();
        long cancelledSessions = mentorSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.CANCELLED).count();

        LocalDateTime weekStart = LocalDateTime.now().minusDays(7);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);

        long sessionsThisWeek = mentorSessions.stream()
                .filter(s -> s.getCreatedAt() != null && s.getCreatedAt().isAfter(weekStart))
                .count();
        long sessionsThisMonth = mentorSessions.stream()
                .filter(s -> s.getCreatedAt() != null && s.getCreatedAt().isAfter(monthStart))
                .count();

        double averageDuration = mentorSessions.stream()
                .filter(s -> s.getStartedAt() != null && s.getEndedAt() != null)
                .mapToLong(s -> java.time.Duration.between(s.getStartedAt(), s.getEndedAt()).toMinutes())
                .average()
                .orElse(0.0);

        double completionRate = totalSessions > 0 ? (double) completedSessions / totalSessions * 100 : 0.0;

        return MentorSessionStatsResponse.builder()
                .totalSessions(totalSessions)
                .scheduledSessions(scheduledSessions)
                .inProgressSessions(inProgressSessions)
                .completedSessions(completedSessions)
                .cancelledSessions(cancelledSessions)
                .sessionsThisWeek(sessionsThisWeek)
                .sessionsThisMonth(sessionsThisMonth)
                .averageSessionDurationMinutes(averageDuration)
                .completionRate(completionRate)
                .build();
    }

    private MentorEarningsResponse getMentorEarnings(User mentor) {
        // TODO: Implement when payment system is added
        return MentorEarningsResponse.builder()
                .totalEarnings(0.0)
                .earningsThisMonth(0.0)
                .earningsLastMonth(0.0)
                .pendingEarnings(0.0)
                .averageEarningsPerSession(0.0)
                .growthRatePercent(0.0)
                .build();
    }

    private MentorRatingResponse getMentorRating(User mentor) {
        List<Feedback> feedbacks = feedbackRepository.findByMentor(mentor);
        long totalReviews = feedbacks.size();

        if (totalReviews == 0) {
            return MentorRatingResponse.builder()
                    .averageRating(0.0)
                    .totalReviews(0L)
                    .fiveStarCount(0L)
                    .fourStarCount(0L)
                    .threeStarCount(0L)
                    .twoStarCount(0L)
                    .oneStarCount(0L)
                    .build();
        }

        double averageRating = feedbacks.stream().mapToInt(Feedback::getRating).average().orElse(0.0);
        long fiveStar = feedbacks.stream().filter(f -> f.getRating() == 5).count();
        long fourStar = feedbacks.stream().filter(f -> f.getRating() == 4).count();
        long threeStar = feedbacks.stream().filter(f -> f.getRating() == 3).count();
        long twoStar = feedbacks.stream().filter(f -> f.getRating() == 2).count();
        long oneStar = feedbacks.stream().filter(f -> f.getRating() == 1).count();

        return MentorRatingResponse.builder()
                .averageRating(averageRating)
                .totalReviews(totalReviews)
                .fiveStarCount(fiveStar)
                .fourStarCount(fourStar)
                .threeStarCount(threeStar)
                .twoStarCount(twoStar)
                .oneStarCount(oneStar)
                .build();
    }

    private MentorUpcomingResponse getMentorUpcoming(User mentor) {
        List<Booking> pendingBookings = bookingRepository.findBySchedule_Mentor(mentor).stream()
                .filter(b -> b.getStatus() == Booking.BookingStatus.PENDING || b.getStatus() == Booking.BookingStatus.CONFIRMED)
                .limit(10)
                .collect(Collectors.toList());

        List<Session> upcomingSessions = sessionRepository.findByMentor(mentor).stream()
                .filter(s -> s.getStatus() == Session.SessionStatus.SCHEDULED)
                .limit(10)
                .collect(Collectors.toList());

        List<UpcomingSessionResponse> sessionResponses = upcomingSessions.stream()
                .map(this::mapToUpcomingSessionResponse)
                .collect(Collectors.toList());

        List<UpcomingBookingResponse> bookingResponses = pendingBookings.stream()
                .map(this::mapToUpcomingBookingResponse)
                .collect(Collectors.toList());

        Session nextSession = upcomingSessions.stream()
                .filter(s -> s.getCreatedAt() != null)
                .min(Comparator.comparing(Session::getCreatedAt))
                .orElse(null);

        return MentorUpcomingResponse.builder()
                .upcomingSessions(sessionResponses)
                .upcomingBookings(bookingResponses)
                .nextSessionId(nextSession != null ? nextSession.getId() : null)
                .nextSessionTime(nextSession != null ? nextSession.getStartedAt() : null)
                .build();
    }

    private UpcomingSessionResponse mapToUpcomingSessionResponse(Session session) {
        return UpcomingSessionResponse.builder()
                .sessionId(session.getId())
                .bookingId(session.getBooking() != null ? session.getBooking().getId() : null)
                .menteeName(session.getMentee() != null ? session.getMentee().getFullName() : "Unknown")
                .menteeAvatar(session.getMentee() != null ? session.getMentee().getAvatar() : null)
                .scheduledStartTime(session.getStartedAt())
                .scheduledEndTime(session.getEndedAt())
                .topicName(session.getBooking() != null && session.getBooking().getSchedule() != null
                        ? session.getBooking().getSchedule().getTopic() : "Unknown")
                .status(session.getStatus().name())
                .build();
    }

    private UpcomingBookingResponse mapToUpcomingBookingResponse(Booking booking) {
        return UpcomingBookingResponse.builder()
                .bookingId(booking.getId())
                .scheduleId(booking.getSchedule() != null ? booking.getSchedule().getId() : null)
                .menteeName(booking.getMentee() != null ? booking.getMentee().getFullName() : "Unknown")
                .menteeAvatar(booking.getMentee() != null ? booking.getMentee().getAvatar() : null)
                .scheduledStartTime(booking.getSchedule() != null ? booking.getSchedule().getStartAt() : null)
                .scheduledEndTime(booking.getSchedule() != null ? booking.getSchedule().getEndAt() : null)
                .topicName(booking.getSchedule() != null && booking.getSchedule().getTopic() != null
                        ? booking.getSchedule().getTopic() : "Unknown")
                .status(booking.getStatus().name())
                .build();
    }

    // ==================== MENTEE DASHBOARD ====================

    @Transactional(readOnly = true)
    public MenteeDashboardResponse getMenteeDashboard(Long menteeId) {
        User mentee = userRepository.findById(menteeId)
                .orElseThrow(() -> new ResourceNotFoundException("Mentee not found with id: " + menteeId));

        Optional<MenteeProfile> profileOpt = menteeProfileRepository.findByUserId(menteeId);

        return MenteeDashboardResponse.builder()
                .profileSummary(getMenteeProfileSummary(mentee, profileOpt))
                .bookingStats(getMenteeBookingStats(mentee))
                .sessionStats(getMenteeSessionStats(mentee))
                .learningProgress(getMenteeLearningProgress(mentee))
                .upcoming(getMenteeUpcoming(mentee))
                .build();
    }

    private MenteeProfileSummaryResponse getMenteeProfileSummary(User mentee, Optional<MenteeProfile> profileOpt) {
        if (profileOpt.isEmpty()) {
            return MenteeProfileSummaryResponse.builder()
                    .menteeId(mentee.getId())
                    .fullName(mentee.getFullName())
                    .avatar(mentee.getAvatar())
                    .school("")
                    .grade("")
                    .learningGoals("")
                    .isProfileComplete(false)
                    .build();
        }

        MenteeProfile profile = profileOpt.get();
        return MenteeProfileSummaryResponse.builder()
                .menteeId(mentee.getId())
                .fullName(profile.getFullName())
                .avatar(profile.getAvatar())
                .school(profile.getSchool())
                .grade(profile.getGrade())
                .learningGoals(profile.getLearningGoals())
                .isProfileComplete(profile.getFullName() != null && profile.getSchool() != null)
                .build();
    }

    private MenteeBookingStatsResponse getMenteeBookingStats(User mentee) {
        List<Booking> menteeBookings = bookingRepository.findByMentee(mentee);
        long totalBookings = menteeBookings.size();
        long pendingBookings = menteeBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.PENDING).count();
        long confirmedBookings = menteeBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CONFIRMED).count();
        long completedBookings = menteeBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED).count();
        long cancelledBookings = menteeBookings.stream().filter(b -> b.getStatus() == Booking.BookingStatus.CANCELLED).count();

        LocalDateTime weekStart = LocalDateTime.now().minusDays(7);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);

        long bookingsThisWeek = menteeBookings.stream()
                .filter(b -> b.getCreatedAt() != null && b.getCreatedAt().isAfter(weekStart))
                .count();
        long bookingsThisMonth = menteeBookings.stream()
                .filter(b -> b.getCreatedAt() != null && b.getCreatedAt().isAfter(monthStart))
                .count();

        return MenteeBookingStatsResponse.builder()
                .totalBookings(totalBookings)
                .pendingBookings(pendingBookings)
                .confirmedBookings(confirmedBookings)
                .completedBookings(completedBookings)
                .cancelledBookings(cancelledBookings)
                .bookingsThisWeek(bookingsThisWeek)
                .bookingsThisMonth(bookingsThisMonth)
                .build();
    }

    private MenteeSessionStatsResponse getMenteeSessionStats(User mentee) {
        List<Session> menteeSessions = sessionRepository.findByMentee(mentee);
        long totalSessions = menteeSessions.size();
        long scheduledSessions = menteeSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.SCHEDULED).count();
        long inProgressSessions = menteeSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.IN_PROGRESS).count();
        long completedSessions = menteeSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.COMPLETED).count();
        long cancelledSessions = menteeSessions.stream().filter(s -> s.getStatus() == Session.SessionStatus.CANCELLED).count();

        LocalDateTime weekStart = LocalDateTime.now().minusDays(7);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);

        long sessionsThisWeek = menteeSessions.stream()
                .filter(s -> s.getCreatedAt() != null && s.getCreatedAt().isAfter(weekStart))
                .count();
        long sessionsThisMonth = menteeSessions.stream()
                .filter(s -> s.getCreatedAt() != null && s.getCreatedAt().isAfter(monthStart))
                .count();

        double averageDuration = menteeSessions.stream()
                .filter(s -> s.getStartedAt() != null && s.getEndedAt() != null)
                .mapToLong(s -> java.time.Duration.between(s.getStartedAt(), s.getEndedAt()).toMinutes())
                .average()
                .orElse(0.0);

        double completionRate = totalSessions > 0 ? (double) completedSessions / totalSessions * 100 : 0.0;

        return MenteeSessionStatsResponse.builder()
                .totalSessions(totalSessions)
                .scheduledSessions(scheduledSessions)
                .inProgressSessions(inProgressSessions)
                .completedSessions(completedSessions)
                .cancelledSessions(cancelledSessions)
                .sessionsThisWeek(sessionsThisWeek)
                .sessionsThisMonth(sessionsThisMonth)
                .averageSessionDurationMinutes(averageDuration)
                .completionRate(completionRate)
                .build();
    }

    private MenteeLearningProgressResponse getMenteeLearningProgress(User mentee) {
        List<Session> completedSessions = sessionRepository.findByMentee(mentee).stream()
                .filter(s -> s.getStatus() == Session.SessionStatus.COMPLETED)
                .collect(Collectors.toList());

        long totalHours = completedSessions.stream()
                .filter(s -> s.getStartedAt() != null && s.getEndedAt() != null)
                .mapToLong(s -> java.time.Duration.between(s.getStartedAt(), s.getEndedAt()).toHours())
                .sum();

        // Get unique topics from mentee's interests
        Optional<MenteeProfile> menteeProfileOpt = menteeProfileRepository.findByUserId(mentee.getId());
        Set<Topic> topicsLearned = menteeProfileOpt.map(MenteeProfile::getInterests).orElse(Collections.emptySet());

        // Get average rating given by this mentee
        List<Feedback> feedbacksGiven = feedbackRepository.findByMentee(mentee);
        double averageRatingGiven = feedbacksGiven.stream()
                .mapToInt(Feedback::getRating)
                .average()
                .orElse(0.0);

        // Topic progress - compare by topic name since Schedule uses String for topic
        List<TopicProgressResponse> topicProgress = topicsLearned.stream()
                .map(topic -> {
                    long sessionsForTopic = completedSessions.stream()
                            .filter(s -> s.getBooking() != null && s.getBooking().getSchedule() != null
                                    && topic.getName().equals(s.getBooking().getSchedule().getTopic()))
                            .count();
                    double avgRating = completedSessions.stream()
                            .filter(s -> s.getBooking() != null && s.getBooking().getSchedule() != null
                                    && topic.getName().equals(s.getBooking().getSchedule().getTopic()))
                            .flatMap(s -> feedbackRepository.findBySession(s).stream())
                            .mapToInt(Feedback::getRating)
                            .average()
                            .orElse(0.0);
                    long hoursForTopic = completedSessions.stream()
                            .filter(s -> s.getBooking() != null && s.getBooking().getSchedule() != null
                                    && topic.getName().equals(s.getBooking().getSchedule().getTopic())
                                    && s.getStartedAt() != null && s.getEndedAt() != null)
                            .mapToLong(s -> java.time.Duration.between(s.getStartedAt(), s.getEndedAt()).toHours())
                            .sum();

                    return TopicProgressResponse.builder()
                            .topicId(topic.getId())
                            .topicName(topic.getName())
                            .sessionsCompleted((int) sessionsForTopic)
                            .averageRating(avgRating)
                            .totalHours(hoursForTopic)
                            .build();
                })
                .collect(Collectors.toList());

        return MenteeLearningProgressResponse.builder()
                .totalTopicsLearned((long) topicsLearned.size())
                .totalHoursLearned(totalHours)
                .averageRatingGiven(averageRatingGiven)
                .topicProgress(topicProgress)
                .build();
    }

    private MenteeUpcomingResponse getMenteeUpcoming(User mentee) {
        List<Booking> pendingBookings = bookingRepository.findByMentee(mentee).stream()
                .filter(b -> b.getStatus() == Booking.BookingStatus.PENDING || b.getStatus() == Booking.BookingStatus.CONFIRMED)
                .limit(10)
                .collect(Collectors.toList());

        List<Session> upcomingSessions = sessionRepository.findByMentee(mentee).stream()
                .filter(s -> s.getStatus() == Session.SessionStatus.SCHEDULED)
                .limit(10)
                .collect(Collectors.toList());

        List<UpcomingSessionResponse> sessionResponses = upcomingSessions.stream()
                .map(this::mapToUpcomingSessionResponse)
                .collect(Collectors.toList());

        List<UpcomingBookingResponse> bookingResponses = pendingBookings.stream()
                .map(this::mapToUpcomingBookingResponse)
                .collect(Collectors.toList());

        Session nextSession = upcomingSessions.stream()
                .filter(s -> s.getCreatedAt() != null)
                .min(Comparator.comparing(Session::getCreatedAt))
                .orElse(null);

        return MenteeUpcomingResponse.builder()
                .upcomingSessions(sessionResponses)
                .upcomingBookings(bookingResponses)
                .nextSessionId(nextSession != null ? nextSession.getId() : null)
                .nextSessionTime(nextSession != null ? nextSession.getStartedAt() : null)
                .nextMentorName(nextSession != null && nextSession.getMentor() != null ? nextSession.getMentor().getFullName() : null)
                .nextTopicName(nextSession != null && nextSession.getBooking() != null && nextSession.getBooking().getSchedule() != null
                        && nextSession.getBooking().getSchedule().getTopic() != null
                        ? nextSession.getBooking().getSchedule().getTopic() : null)
                .build();
    }
}