-- V5: Create user_permissions table
CREATE TABLE IF NOT EXISTS `user_permissions` (
    `user_id` INT NOT NULL,
    `permission_id` INT NOT NULL,
    `is_granted` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`, `permission_id`),
    INDEX `idx_user_permissions_user_id` (`user_id`),
    INDEX `idx_user_permissions_permission_id` (`permission_id`),
    CONSTRAINT `fk_user_permissions_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_user_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;