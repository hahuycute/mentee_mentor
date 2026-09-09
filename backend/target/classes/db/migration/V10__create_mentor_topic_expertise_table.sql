-- V10: Create mentor_topic_expertise table (join table)
CREATE TABLE IF NOT EXISTS `mentor_topic_expertise` (
    `mentor_profile_id` INT NOT NULL,
    `topic_id` INT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`mentor_profile_id`, `topic_id`),
    INDEX `idx_mentor_topic_expertise_mentor_profile_id` (`mentor_profile_id`),
    INDEX `idx_mentor_topic_expertise_topic_id` (`topic_id`),
    CONSTRAINT `fk_mentor_topic_expertise_mentor_profile` FOREIGN KEY (`mentor_profile_id`) REFERENCES `mentor_profiles`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_mentor_topic_expertise_topic` FOREIGN KEY (`topic_id`) REFERENCES `topics`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;