package com.example.germanlearningapp.service;

import com.example.germanlearningapp.dto.GrammarQuestionDto;
import com.example.germanlearningapp.dto.GrammarTopicDto;
import com.example.germanlearningapp.entity.GrammarQuestion;
import com.example.germanlearningapp.entity.GrammarTopic;
import com.example.germanlearningapp.repository.GrammarQuestionRepository;
import com.example.germanlearningapp.repository.GrammarTopicRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class GrammarService {

    private final GrammarTopicRepository topicRepository;
    private final GrammarQuestionRepository questionRepository;

    public GrammarService(
            GrammarTopicRepository topicRepository,
            GrammarQuestionRepository questionRepository
    ) {
        this.topicRepository = topicRepository;
        this.questionRepository = questionRepository;
    }

    public List<GrammarTopicDto> getTopics(String level) {
        List<GrammarTopic> topics = level == null || level.isBlank()
                ? topicRepository.findAll(Sort.by(Sort.Direction.ASC, "id"))
                : topicRepository.findByLevelOrderByIdAsc(level);

        return topics
                .stream()
                .map(this::toTopicDto)
                .toList();
    }

    public GrammarTopicDto getTopicById(Long id) {
        return topicRepository.findById(id)
                .map(this::toTopicDto)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar topic not found"));
    }

    public List<GrammarQuestionDto> getQuestions(Long topicId, String level) {
        List<GrammarQuestion> questions;
        if (topicId != null && level != null && !level.isBlank()) {
            questions = questionRepository.findByTopicIdAndLevelOrderByIdAsc(topicId, level);
        } else if (topicId != null) {
            questions = questionRepository.findByTopicIdOrderByIdAsc(topicId);
        } else if (level != null && !level.isBlank()) {
            questions = questionRepository.findByLevelOrderByIdAsc(level);
        } else {
            questions = questionRepository.findAll(Sort.by(Sort.Direction.ASC, "id"));
        }

        return questions.stream()
                .map(this::toQuestionDto)
                .toList();
    }

    public GrammarQuestionDto getQuestionById(Long id) {
        return questionRepository.findById(id)
                .map(this::toQuestionDto)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar question not found"));
    }

    private GrammarTopicDto toTopicDto(GrammarTopic topic) {
        return new GrammarTopicDto(
                topic.getId(),
                topic.getTitle(),
                topic.getDescription(),
                topic.getLevel()
        );
    }

    private GrammarQuestionDto toQuestionDto(GrammarQuestion question) {
        return new GrammarQuestionDto(
                question.getId(),
                question.getTopic().getId(),
                question.getTopic().getTitle(),
                question.getQuestion(),
                question.getOptions(),
                question.getCorrectAnswerIndex(),
                question.getExplanation(),
                question.getLevel()
        );
    }
}
