-- V14: Create feedbacks table
CREATE TABLE IF NOT EXISTS `feedbacks` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `session_id` INT NOT NULL UNIQUE,
    `mentor_id` INT NOT NULL,
    `mentee_id` INT NOT NULL,
    `rating` INT NOT NULL,
    `comment` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_feedbacks_session_id` (`session_id`),
    INDEX `idx_feedbacks_mentee_id` (`mentee_id`),
    INDEX `idx_feedbacks_mentor_id` (`mentor_id`),
    INDEX `idx_feedbacks_rating` (`rating`),
    CONSTRAINT `fk_feedbacks_session` FOREIGN KEY (`session_id`) REFERENCES `sessions`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_feedbacks_mentor` FOREIGN KEY (`mentor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_feedbacks_mentee` FOREIGN KEY (`mentee_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;