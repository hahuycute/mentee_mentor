-- V8: Create mentee_profiles table
CREATE TABLE IF NOT EXISTS `mentee_profiles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL UNIQUE,
    `full_name` VARCHAR(255) NOT NULL,
    `avatar` VARCHAR(500),
    `phone_number` VARCHAR(20),
    `goals` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_mentee_profiles_user_id` (`user_id`),
    CONSTRAINT `fk_mentee_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;