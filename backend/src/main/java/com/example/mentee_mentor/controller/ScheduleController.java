package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.schedule.ScheduleRequest;
import com.example.mentee_mentor.dto.schedule.ScheduleResponse;
import com.example.mentee_mentor.model.Schedule;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.ScheduleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("/my")
    public ResponseEntity<Page<ScheduleResponse>> getMySchedules(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "startAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<ScheduleResponse> schedules = scheduleService.getMySchedules(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ScheduleResponse> getSchedule(@PathVariable Long id) {
        ScheduleResponse schedule = scheduleService.getScheduleById(id);
        return ResponseEntity.ok(schedule);
    }

    @PostMapping
    public ResponseEntity<ScheduleResponse> createSchedule(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody ScheduleRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        ScheduleResponse schedule = scheduleService.createSchedule(userPrincipal.getId(), request);
        return ResponseEntity.ok(schedule);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ScheduleResponse> updateSchedule(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @Valid @RequestBody ScheduleRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        ScheduleResponse schedule = scheduleService.updateSchedule(id, request);
        return ResponseEntity.ok(schedule);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ScheduleResponse> updateScheduleStatus(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @RequestBody Schedule.ScheduleStatus status) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        ScheduleResponse schedule = scheduleService.updateScheduleStatus(id, status);
        return ResponseEntity.ok(schedule);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        scheduleService.deleteSchedule(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<Page<ScheduleResponse>> getAvailableSchedules(
            @PageableDefault(size = 10, sort = "startAt") Pageable pageable) {
        Page<ScheduleResponse> schedules = scheduleService.getAvailableSchedules(LocalDateTime.now(), pageable);
        return ResponseEntity.ok(schedules);
    }
}