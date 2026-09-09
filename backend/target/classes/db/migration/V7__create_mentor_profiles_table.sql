-- V7: Create mentor_profiles table
CREATE TABLE IF NOT EXISTS `mentor_profiles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL UNIQUE,
    `full_name` VARCHAR(255) NOT NULL,
    `avatar` VARCHAR(500),
    `phone_number` VARCHAR(20),
    `school` VARCHAR(255),
    `degree` VARCHAR(255),
    `years_exp` INT,
    `bio` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_mentor_profiles_user_id` (`user_id`),
    FULLTEXT KEY `ft_mentor_profiles_full_name` (`full_name`),
    CONSTRAINT `fk_mentor_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;