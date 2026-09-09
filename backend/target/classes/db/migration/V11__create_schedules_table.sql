-- V11: Create schedules table
CREATE TABLE IF NOT EXISTS `schedules` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `mentor_id` INT NOT NULL,
    `topic` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `start_at` DATETIME NOT NULL,
    `end_at` DATETIME NOT NULL,
    `capacity` INT NOT NULL DEFAULT 1,
    `status` ENUM('AVAILABLE', 'BOOKED', 'CANCELLED') NOT NULL DEFAULT 'AVAILABLE',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_schedules_mentor_id_start_at` (`mentor_id`, `start_at`),
    INDEX `idx_schedules_status` (`status`),
    CONSTRAINT `fk_schedules_mentor` FOREIGN KEY (`mentor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;