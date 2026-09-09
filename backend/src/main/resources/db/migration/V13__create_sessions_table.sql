-- V13: Create sessions table
CREATE TABLE IF NOT EXISTS `sessions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `booking_id` INT NOT NULL UNIQUE,
    `mentor_id` INT NOT NULL,
    `mentee_id` INT NOT NULL,
    `started_at` DATETIME,
    `ended_at` DATETIME,
    `status` ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    `notes` TEXT,
    `auto_started` BOOLEAN NOT NULL DEFAULT FALSE,
    `auto_ended` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_sessions_booking_id` (`booking_id`),
    INDEX `idx_sessions_mentee_id` (`mentee_id`),
    INDEX `idx_sessions_mentor_id` (`mentor_id`),
    INDEX `idx_sessions_status` (`status`),
    CONSTRAINT `fk_sessions_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sessions_mentor` FOREIGN KEY (`mentor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sessions_mentee` FOREIGN KEY (`mentee_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;