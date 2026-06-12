package com.example.germanlearningapp.dto;

import java.util.List;

public record GrammarQuestionDto(
        Long id,
        Long topicId,
        String topicTitle,
        String question,
        List<String> options,
        Integer correctAnswerIndex,
        String explanation,
        String level
) {
}
