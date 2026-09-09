package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Schedule;
import com.example.mentee_mentor.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    List<Schedule> findByMentor(User mentor);

    Page<Schedule> findByMentor(User mentor, Pageable pageable);

    @Query("SELECT s FROM Schedule s WHERE s.mentor = :mentor AND s.startAt >= :now ORDER BY s.startAt")
    List<Schedule> findUpcomingByMentor(@Param("mentor") User mentor, @Param("now") LocalDateTime now);

    List<Schedule> findByStatus(Schedule.ScheduleStatus status);

    @Query("SELECT s FROM Schedule s WHERE s.status = :status AND s.startAt >= :now ORDER BY s.startAt")
    List<Schedule> findAvailableSchedules(@Param("status") Schedule.ScheduleStatus status, @Param("now") LocalDateTime now);

    @Query("SELECT s FROM Schedule s WHERE s.status = :status AND s.startAt >= :now ORDER BY s.startAt")
    Page<Schedule> findAvailableSchedules(@Param("status") Schedule.ScheduleStatus status, @Param("now") LocalDateTime now, Pageable pageable);
}