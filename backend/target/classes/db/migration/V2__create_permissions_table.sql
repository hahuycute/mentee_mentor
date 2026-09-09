-- V2: Create permissions table
CREATE TABLE IF NOT EXISTS `permissions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `code` VARCHAR(100) NOT NULL UNIQUE,
    `resource` VARCHAR(50) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `description` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_permissions_resource` (`resource`),
    INDEX `idx_permissions_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;