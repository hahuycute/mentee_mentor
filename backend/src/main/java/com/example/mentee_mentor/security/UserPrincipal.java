package com.example.mentee_mentor.security;

import com.example.mentee_mentor.model.Role;
import com.example.mentee_mentor.model.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class UserPrincipal implements UserDetails {

    private final Long id;
    private final String email;
    private final String password;
    private final Collection<? extends GrantedAuthority> authorities;
    private final User.UserRole role;
    private final User user;

    public UserPrincipal(Long id, String email, String password, User.UserRole role, Collection<? extends GrantedAuthority> authorities, User user) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.role = role;
        this.authorities = authorities;
        this.user = user;
    }

    public static UserPrincipal create(User user) {
        List<GrantedAuthority> authorities = user.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
                .collect(Collectors.toList());

        // Add user permissions
        if (user.getPermissions() != null) {
            authorities.addAll(user.getPermissions().stream()
                    .map(p -> new SimpleGrantedAuthority(p.getCode()))
                    .collect(Collectors.toList()));
        }

        // Add role permissions
        if (user.getRoles() != null) {
            for (Role role : user.getRoles()) {
                if (role.getPermissions() != null) {
                    authorities.addAll(role.getPermissions().stream()
                            .map(p -> new SimpleGrantedAuthority(p.getCode()))
                            .collect(Collectors.toList()));
                }
            }
        }

        return new UserPrincipal(
                user.getId(),
                user.getEmail(),
                user.getPassword(),
                user.getRole(),
                authorities,
                user
        );
    }

    public Long getId() {
        return id;
    }

    public User.UserRole getRole() {
        return role;
    }

    public User getUser() {
        return user;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return user.getIsActive() != null && user.getIsActive();
    }
}