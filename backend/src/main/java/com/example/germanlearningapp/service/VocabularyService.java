package com.example.germanlearningapp.service;

import com.example.germanlearningapp.dto.VocabularyCategoryDto;
import com.example.germanlearningapp.dto.VocabularyDto;
import com.example.germanlearningapp.entity.Vocabulary;
import com.example.germanlearningapp.entity.VocabularyCategory;
import com.example.germanlearningapp.repository.VocabularyCategoryRepository;
import com.example.germanlearningapp.repository.VocabularyRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VocabularyService {

    private final VocabularyCategoryRepository categoryRepository;
    private final VocabularyRepository vocabularyRepository;

    public VocabularyService(
            VocabularyCategoryRepository categoryRepository,
            VocabularyRepository vocabularyRepository
    ) {
        this.categoryRepository = categoryRepository;
        this.vocabularyRepository = vocabularyRepository;
    }

    public List<VocabularyCategoryDto> getCategories() {
        return categoryRepository.findAll(Sort.by(Sort.Direction.ASC, "id"))
                .stream()
                .map(this::toCategoryDto)
                .toList();
    }

    public VocabularyCategoryDto getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .map(this::toCategoryDto)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary category not found"));
    }

    public List<VocabularyDto> getVocabulary(Long categoryId, String level) {
        List<Vocabulary> vocabulary;
        if (categoryId != null && level != null && !level.isBlank()) {
            vocabulary = vocabularyRepository.findByCategoryIdAndLevelOrderByGermanAsc(categoryId, level);
        } else if (categoryId != null) {
            vocabulary = vocabularyRepository.findByCategoryIdOrderByGermanAsc(categoryId);
        } else if (level != null && !level.isBlank()) {
            vocabulary = vocabularyRepository.findByLevelOrderByGermanAsc(level);
        } else {
            vocabulary = vocabularyRepository.findAll(Sort.by(Sort.Direction.ASC, "german"));
        }

        return vocabulary.stream()
                .map(this::toVocabularyDto)
                .toList();
    }

    public VocabularyDto getVocabularyById(Long id) {
        return vocabularyRepository.findById(id)
                .map(this::toVocabularyDto)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary item not found"));
    }

    private VocabularyCategoryDto toCategoryDto(VocabularyCategory category) {
        return new VocabularyCategoryDto(
                category.getId(),
                category.getName(),
                category.getDescription(),
                category.getIconName()
        );
    }

    private VocabularyDto toVocabularyDto(Vocabulary vocabulary) {
        return new VocabularyDto(
                vocabulary.getId(),
                vocabulary.getGerman(),
                vocabulary.getEnglish(),
                vocabulary.getCategory().getId(),
                vocabulary.getCategory().getName(),
                vocabulary.getLevel(),
                vocabulary.getExampleGerman(),
                vocabulary.getExampleEnglish()
        );
    }
}
