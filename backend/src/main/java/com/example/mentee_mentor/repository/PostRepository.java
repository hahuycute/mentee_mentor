package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Post;
import com.example.mentee_mentor.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {

    Page<Post> findByIsPublicTrueOrderByCreatedAtDesc(Pageable pageable);

    Page<Post> findByAuthorOrderByCreatedAtDesc(User author, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.isPublic = true AND (p.title LIKE %:keyword% OR p.content LIKE %:keyword%) ORDER BY p.createdAt DESC")
    Page<Post> searchPublicPosts(@Param("keyword") String keyword, Pageable pageable);

    List<Post> findByAuthor(User author);
}