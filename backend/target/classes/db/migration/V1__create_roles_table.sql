-- V1: Create roles table
CREATE TABLE IF NOT EXISTS `roles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default roles
INSERT INTO `roles` (`name`, `description`) VALUES
    ('ADMIN', 'Administrator with full access'),
    ('MENTOR', 'Mentor who provides guidance'),
    ('MENTEE', 'Mentee who seeks guidance')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);