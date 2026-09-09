-- V17: Create post_images table
CREATE TABLE IF NOT EXISTS `post_images` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `post_id` INT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `display_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_post_images_post_id` (`post_id`),
    CONSTRAINT `fk_post_images_post` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;