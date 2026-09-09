package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Like;
import com.example.mentee_mentor.model.Post;
import com.example.mentee_mentor.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {

    Optional<Like> findByPostAndUser(Post post, User user);

    long countByPost(Post post);

    boolean existsByPostAndUser(Post post, User user);
}