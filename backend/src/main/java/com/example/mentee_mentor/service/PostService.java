package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.post.PostRequest;
import com.example.mentee_mentor.dto.post.PostResponse;
import com.example.mentee_mentor.model.Like;
import com.example.mentee_mentor.model.Post;
import com.example.mentee_mentor.model.PostImage;
import com.example.mentee_mentor.model.User;
import com.example.mentee_mentor.repository.LikeRepository;
import com.example.mentee_mentor.repository.PostImageRepository;
import com.example.mentee_mentor.repository.PostRepository;
import com.example.mentee_mentor.repository.UserRepository;
import com.example.mentee_mentor.exception.ResourceNotFoundException;
import com.example.mentee_mentor.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final LikeRepository likeRepository;
    private final UserRepository userRepository;
    private final PostImageRepository postImageRepository;

    @Transactional
    public PostResponse createPost(Long authorId, PostRequest request) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + authorId));

        Post post = Post.builder()
                .author(author)
                .title(request.getTitle())
                .content(request.getContent())
                .isPublic(request.getIsPublic())
                .build();

        Post saved = postRepository.save(post);

        // Save images if provided
        if (request.getImageUrls() != null && !request.getImageUrls().isEmpty()) {
            List<PostImage> images = request.getImageUrls().stream()
                    .map(url -> PostImage.builder()
                            .post(saved)
                            .imageUrl(url)
                            .displayOrder(request.getImageUrls().indexOf(url))
                            .build())
                    .collect(Collectors.toList());
            postImageRepository.saveAll(images);
        }

        boolean liked = likeRepository.existsByPostAndUser(saved, author);
        return PostResponse.fromEntity(saved, liked);
    }

    @Transactional(readOnly = true)
    public Page<PostResponse> getPublicPosts(Pageable pageable, Long currentUserId) {
        Page<Post> posts = postRepository.findByIsPublicTrueOrderByCreatedAtDesc(pageable);

        User currentUser = currentUserId != null ? userRepository.findById(currentUserId).orElse(null) : null;

        return posts.map(post -> {
            boolean liked = currentUser != null && likeRepository.existsByPostAndUser(post, currentUser);
            return PostResponse.fromEntity(post, liked);
        });
    }

    @Transactional(readOnly = true)
    public Page<PostResponse> searchPublicPosts(String keyword, Pageable pageable, Long currentUserId) {
        Page<Post> posts = postRepository.searchPublicPosts(keyword, pageable);

        User currentUser = currentUserId != null ? userRepository.findById(currentUserId).orElse(null) : null;

        return posts.map(post -> {
            boolean liked = currentUser != null && likeRepository.existsByPostAndUser(post, currentUser);
            return PostResponse.fromEntity(post, liked);
        });
    }

    @Transactional(readOnly = true)
    public Page<PostResponse> getMyPosts(Long authorId, Pageable pageable) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + authorId));

        Page<Post> posts = postRepository.findByAuthorOrderByCreatedAtDesc(author, pageable);

        return posts.map(post -> {
            boolean liked = likeRepository.existsByPostAndUser(post, author);
            return PostResponse.fromEntity(post, liked);
        });
    }

    @Transactional(readOnly = true)
    public PostResponse getPostById(Long postId, Long currentUserId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found with id: " + postId));

        User currentUser = currentUserId != null ? userRepository.findById(currentUserId).orElse(null) : null;
        boolean liked = currentUser != null && likeRepository.existsByPostAndUser(post, currentUser);

        return PostResponse.fromEntity(post, liked);
    }

    @Transactional
    public PostResponse updatePost(Long authorId, Long postId, PostRequest request) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + authorId));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found with id: " + postId));

        if (!post.getAuthor().getId().equals(authorId)) {
            throw new BadRequestException("You don't have permission to update this post");
        }

        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setIsPublic(request.getIsPublic());

        Post saved = postRepository.save(post);

        boolean liked = likeRepository.existsByPostAndUser(saved, author);
        return PostResponse.fromEntity(saved, liked);
    }

    @Transactional
    public void deletePost(Long authorId, Long postId) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + authorId));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found with id: " + postId));

        if (!post.getAuthor().getId().equals(authorId)) {
            throw new BadRequestException("You don't have permission to delete this post");
        }

        postImageRepository.deleteByPost(post);
        postRepository.delete(post);
    }

    @Transactional
    public PostResponse likePost(Long userId, Long postId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found with id: " + postId));

        if (likeRepository.existsByPostAndUser(post, user)) {
            throw new BadRequestException("You have already liked this post");
        }

        Like like = Like.builder().post(post).user(user).build();
        likeRepository.save(like);

        boolean liked = true;
        return PostResponse.fromEntity(post, liked);
    }

    @Transactional
    public PostResponse unlikePost(Long userId, Long postId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found with id: " + postId));

        Like like = likeRepository.findByPostAndUser(post, user)
                .orElseThrow(() -> new BadRequestException("You haven't liked this post"));

        likeRepository.delete(like);

        boolean liked = false;
        return PostResponse.fromEntity(post, liked);
    }
}