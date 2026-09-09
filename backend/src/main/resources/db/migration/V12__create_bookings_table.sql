-- V12: Create bookings table
CREATE TABLE IF NOT EXISTS `bookings` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `schedule_id` INT NOT NULL,
    `mentee_id` INT NOT NULL,
    `status` ENUM('PENDING', 'CONFIRMED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    `notes` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_bookings_schedule_id_mentee_id` (`schedule_id`, `mentee_id`),
    INDEX `idx_bookings_mentee_id` (`mentee_id`),
    CONSTRAINT `fk_bookings_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedules`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_bookings_mentee` FOREIGN KEY (`mentee_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;