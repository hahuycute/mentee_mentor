package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.model.Schedule;
import com.example.mentee_mentor.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByMentee(User mentee);

    List<Booking> findBySchedule(Schedule schedule);

    Page<Booking> findByMentee(User mentee, Pageable pageable);

    @Query("SELECT b FROM Booking b WHERE b.schedule.mentor = :mentor")
    List<Booking> findBySchedule_Mentor(@Param("mentor") User mentor);

    @Query("SELECT b FROM Booking b WHERE b.schedule.mentor = :mentor")
    Page<Booking> findBySchedule_Mentor(@Param("mentor") User mentor, Pageable pageable);

    Optional<Booking> findByScheduleAndMentee(Schedule schedule, User mentee);

    List<Booking> findByStatus(Booking.BookingStatus status);
}