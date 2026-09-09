package com.example.mentee_mentor.repository;

import com.example.mentee_mentor.model.Permission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PermissionRepository extends JpaRepository<Permission, Long> {

    Optional<Permission> findByCode(String code);

    List<Permission> findByResource(String resource);

    List<Permission> findByResourceAndAction(String resource, String action);
}