package com.example.mentee_mentor.controller;

import com.example.mentee_mentor.dto.booking.BookingRequest;
import com.example.mentee_mentor.dto.booking.BookingResponse;
import com.example.mentee_mentor.model.Booking;
import com.example.mentee_mentor.security.UserPrincipal;
import com.example.mentee_mentor.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    public ResponseEntity<BookingResponse> createBooking(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody BookingRequest request) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        BookingResponse booking = bookingService.createBooking(userPrincipal.getId(), request);
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/my")
    public ResponseEntity<Page<BookingResponse>> getMyBookings(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        Page<BookingResponse> bookings = bookingService.getMyBookings(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/{id}")
    public ResponseEntity<BookingResponse> getBooking(@PathVariable Long id) {
        BookingResponse booking = bookingService.getBookingById(id);
        return ResponseEntity.ok(booking);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<BookingResponse> updateBookingStatus(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id,
            @RequestBody Booking.BookingStatus status) {
        if (userPrincipal == null) {
            return ResponseEntity.status(401).build();
        }
        BookingResponse booking = bookingService.updateBookingStatus(id, status, userPrincipal.getId());
        return ResponseEntity.ok(booking);
    }
}