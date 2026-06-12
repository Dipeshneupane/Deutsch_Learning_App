package com.example.germanlearningapp.dto;

public record VocabularyDto(
        Long id,
        String german,
        String english,
        Long categoryId,
        String categoryName,
        String level,
        String exampleGerman,
        String exampleEnglish
) {
}
