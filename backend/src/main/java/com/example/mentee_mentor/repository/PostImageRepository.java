package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.PostImage;
import com.example.mentee_mentor.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface PostImageRepository extends JpaRepository<PostImage, Long> {

    List<PostImage> findByPostOrderByDisplayOrderAsc(Post post);

    @Modifying
    @Transactional
    @Query("DELETE FROM PostImage pi WHERE pi.post = :post")
    void deleteByPost(@Param("post") Post post);
}