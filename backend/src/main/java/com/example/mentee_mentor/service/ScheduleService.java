package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.schedule.ScheduleRequest;
import com.example.mentee_mentor.dto.schedule.ScheduleResponse;
import com.example.mentee_mentor.model.Schedule;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.ScheduleRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<ScheduleResponse> getMySchedules(Long mentorId, Pageable pageable) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));
        return scheduleRepository.findByMentor(mentor, pageable).map(ScheduleResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public ScheduleResponse getScheduleById(Long scheduleId) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule not found with id: " + scheduleId));
        return ScheduleResponse.fromEntity(schedule);
    }

    @Transactional
    public ScheduleResponse createSchedule(Long mentorId, ScheduleRequest request) {
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + mentorId));

        if (!mentor.getRole().equals(User.UserRole.MENTOR)) {
            throw new IllegalArgumentException("Only mentors can create schedules");
        }

        Schedule schedule = Schedule.builder()
                .mentor(mentor)
                .topic(request.getTopic())
                .description(request.getDescription())
                .startAt(request.getStartAt())
                .endAt(request.getEndAt())
                .capacity(request.getCapacity())
                .status(request.getStatus())
                .build();

        Schedule saved = scheduleRepository.save(schedule);
        return ScheduleResponse.fromEntity(saved);
    }

    @Transactional
    public ScheduleResponse updateSchedule(Long scheduleId, ScheduleRequest request) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule not found with id: " + scheduleId));

        schedule.setTopic(request.getTopic());
        schedule.setDescription(request.getDescription());
        schedule.setStartAt(request.getStartAt());
        schedule.setEndAt(request.getEndAt());
        schedule.setCapacity(request.getCapacity());
        schedule.setStatus(request.getStatus());

        Schedule saved = scheduleRepository.save(schedule);
        return ScheduleResponse.fromEntity(saved);
    }

    @Transactional
    public ScheduleResponse updateScheduleStatus(Long scheduleId, Schedule.ScheduleStatus status) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule not found with id: " + scheduleId));

        schedule.setStatus(status);
        Schedule saved = scheduleRepository.save(schedule);
        return ScheduleResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteSchedule(Long scheduleId) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Schedule not found with id: " + scheduleId));
        scheduleRepository.delete(schedule);
    }

    @Transactional(readOnly = true)
    public Page<ScheduleResponse> getAvailableSchedules(LocalDateTime now, Pageable pageable) {
        return scheduleRepository.findAvailableSchedules(Schedule.ScheduleStatus.AVAILABLE, now, pageable)
                .map(ScheduleResponse::fromEntity);
    }
}