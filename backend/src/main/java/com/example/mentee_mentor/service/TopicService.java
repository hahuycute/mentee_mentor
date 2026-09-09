package com.example.mentee_mentor.service;

import com.example.mentee_mentor.dto.topic.TopicRequest;
import com.example.mentee_mentor.dto.topic.TopicResponse;
import com.example.mentee_mentor.model.Topic;
import com.example.mentee_mentor.repository.TopicRepository;
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
public class TopicService {

    private final TopicRepository topicRepository;

    @Transactional
    public TopicResponse createTopic(TopicRequest request) {
        if (topicRepository.findByName(request.getName()).isPresent()) {
            throw new BadRequestException("Topic with name '" + request.getName() + "' already exists");
        }

        Topic topic = Topic.builder()
                .name(request.getName())
                .description(request.getDescription())
                .icon(request.getIcon())
                .color(request.getColor())
                .build();

        Topic saved = topicRepository.save(topic);
        return TopicResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public Page<TopicResponse> getAllTopics(Pageable pageable) {
        Page<Topic> topics = topicRepository.findAll(pageable);
        return topics.map(TopicResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public List<TopicResponse> getAllTopics() {
        List<Topic> topics = topicRepository.findAll();
        return topics.stream().map(TopicResponse::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TopicResponse getTopicById(Long id) {
        Topic topic = topicRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Topic not found with id: " + id));
        return TopicResponse.fromEntity(topic);
    }

    @Transactional
    public TopicResponse updateTopic(Long id, TopicRequest request) {
        Topic topic = topicRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Topic not found with id: " + id));

        if (!topic.getName().equals(request.getName()) && topicRepository.findByName(request.getName()).isPresent()) {
            throw new BadRequestException("Topic with name '" + request.getName() + "' already exists");
        }

        topic.setName(request.getName());
        topic.setDescription(request.getDescription());
        topic.setIcon(request.getIcon());
        topic.setColor(request.getColor());

        Topic saved = topicRepository.save(topic);
        return TopicResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteTopic(Long id) {
        Topic topic = topicRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Topic not found with id: " + id));
        topicRepository.delete(topic);
    }
}