-- V20: Create password_resets table
CREATE TABLE IF NOT EXISTS `password_resets` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `otp` VARCHAR(6) NOT NULL,
    `expires_at` DATETIME NOT NULL,
    `attempts` INT NOT NULL DEFAULT 0,
    `last_sent_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_used` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_password_resets_email` (`email`),
    INDEX `idx_password_resets_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
