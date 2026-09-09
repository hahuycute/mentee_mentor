package com.example.mentee_mentor.dto.post;

import com.example.mentee_mentor.model.Post;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostResponse {

    private Long id;
    private Long authorId;
    private String authorName;
    private String authorAvatar;
    private String title;
    private String content;
    private Boolean isPublic;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String> images;
    private long likeCount;
    private boolean likedByCurrentUser;

    public static PostResponse fromEntity(Post post, boolean likedByCurrentUser) {
        if (post == null) return null;

        return PostResponse.builder()
                .id(post.getId())
                .authorId(post.getAuthor() != null ? post.getAuthor().getId() : null)
                .authorName(post.getAuthor() != null ? post.getAuthor().getFullName() : null)
                .authorAvatar(post.getAuthor() != null ? post.getAuthor().getAvatar() : null)
                .title(post.getTitle())
                .content(post.getContent())
                .isPublic(post.getIsPublic())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .images(post.getImages().stream().map(img -> img.getImageUrl()).toList())
                .likeCount(post.getLikes().size())
                .likedByCurrentUser(likedByCurrentUser)
                .build();
    }
}