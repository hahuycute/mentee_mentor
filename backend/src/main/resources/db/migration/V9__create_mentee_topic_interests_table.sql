-- V9: Create mentee_topic_interests table (join table)
CREATE TABLE IF NOT EXISTS `mentee_topic_interests` (
    `mentee_profile_id` INT NOT NULL,
    `topic_id` INT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`mentee_profile_id`, `topic_id`),
    INDEX `idx_mentee_topic_interests_mentee_profile_id` (`mentee_profile_id`),
    INDEX `idx_mentee_topic_interests_topic_id` (`topic_id`),
    CONSTRAINT `fk_mentee_topic_interests_mentee_profile` FOREIGN KEY (`mentee_profile_id`) REFERENCES `mentee_profiles`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_mentee_topic_interests_topic` FOREIGN KEY (`topic_id`) REFERENCES `topics`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;