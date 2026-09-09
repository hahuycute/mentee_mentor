-- V18: Create likes table
CREATE TABLE IF NOT EXISTS `likes` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `post_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_likes_post_id_user_id` (`post_id`, `user_id`),
    INDEX `idx_likes_post_id` (`post_id`),
    INDEX `idx_likes_user_id` (`user_id`),
    CONSTRAINT `fk_likes_post` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;