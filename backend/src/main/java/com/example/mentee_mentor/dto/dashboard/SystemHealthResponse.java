package com.example.mentee_mentor.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemHealthResponse {

    private String databaseStatus;
    private String apiResponseTime;
    private Long activeConnections;
    private Long errorRateLastHour;
    private String lastBackupTime;
}