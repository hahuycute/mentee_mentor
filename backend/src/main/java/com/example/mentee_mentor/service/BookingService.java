package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.booking.BookingRequest;
import com.example.mentee_mentor.dto.booking.BookingResponse;
import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.model.Schedule;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.BookingRepository;
import com.example.mentee_mentor.repository.ScheduleRepository;
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
public class BookingService {

    private final BookingRepository bookingRepository;
    private final ScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    @Transactional
    public BookingResponse createBooking(Long menteeId, BookingRequest request) {
        User mentee = userRepository.findById(menteeId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + menteeId));

        Schedule schedule = scheduleRepository.findById(request.getScheduleId())
                .orElseThrow(() -> new ResourceNotFoundException("Schedule not found with id: " + request.getScheduleId()));

        // Check if schedule is available
        if (!schedule.getStatus().equals(Schedule.ScheduleStatus.AVAILABLE)) {
            throw new BadRequestException("Schedule is not available for booking");
        }

        // Check if already booked by this mentee
        Optional<Booking> existing = bookingRepository.findByScheduleAndMentee(schedule, mentee);
        if (existing.isPresent()) {
            throw new BadRequestException("You have already booked this schedule");
        }

        // Check capacity
        long currentBookings = bookingRepository.findBySchedule(schedule).stream()
                .filter(b -> !b.getStatus().equals(Booking.BookingStatus.CANCELLED))
                .count();
        if (currentBookings >= schedule.getCapacity()) {
            throw new BadRequestException("Schedule is fully booked");
        }

        Booking booking = Booking.builder()
                .schedule(schedule)
                .mentee(mentee)
                .status(Booking.BookingStatus.PENDING)
                .notes(request.getNotes())
                .build();

        Booking saved = bookingRepository.save(booking);
        return BookingResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public Page<BookingResponse> getMyBookings(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // User can be either mentee or mentor
        List<Booking> bookings;
        if (user.getRole().equals(User.UserRole.MENTOR)) {
            // Find bookings for schedules created by this mentor
            bookings = bookingRepository.findBySchedule_Mentor(user);
        } else {
            bookings = bookingRepository.findByMentee(user);
        }

        // Convert to page (simplified - in real app use proper pagination)
        return new org.springframework.data.domain.PageImpl<>(
                bookings.stream().map(BookingResponse::fromEntity).collect(Collectors.toList()),
                pageable,
                bookings.size()
        );
    }

    @Transactional(readOnly = true)
    public BookingResponse getBookingById(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + bookingId));
        return BookingResponse.fromEntity(booking);
    }

    @Transactional
    public BookingResponse updateBookingStatus(Long bookingId, Booking.BookingStatus status, Long userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + bookingId));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Check permissions
        boolean isMentor = booking.getSchedule().getMentor().getId().equals(userId);
        boolean isMentee = booking.getMentee().getId().equals(userId);

        if (!isMentor && !isMentee) {
            throw new BadRequestException("You don't have permission to update this booking");
        }

        // Validate status transitions
        if (isMentor) {
            if (status == Booking.BookingStatus.CONFIRMED && booking.getStatus() != Booking.BookingStatus.PENDING) {
                throw new BadRequestException("Only pending bookings can be confirmed");
            }
            if (status == Booking.BookingStatus.CANCELLED && booking.getStatus() == Booking.BookingStatus.COMPLETED) {
                throw new BadRequestException("Completed bookings cannot be cancelled");
            }
        }

        if (isMentee) {
            if (status == Booking.BookingStatus.CANCELLED &&
                    (booking.getStatus() == Booking.BookingStatus.COMPLETED || booking.getStatus() == Booking.BookingStatus.CANCELLED)) {
                throw new BadRequestException("Cannot cancel this booking");
            }
        }

        booking.setStatus(status);
        Booking saved = bookingRepository.save(booking);
        return BookingResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public long countBookingsByMentor(Long mentorId) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));
        return bookingRepository.findBySchedule_Mentor(mentor).size();
    }
}