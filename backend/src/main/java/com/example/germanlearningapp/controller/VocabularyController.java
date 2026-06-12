package com.example.germanlearningapp.controller;

import com.example.germanlearningapp.dto.VocabularyCategoryDto;
import com.example.germanlearningapp.dto.VocabularyDto;
import com.example.germanlearningapp.service.VocabularyService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/vocab")
public class VocabularyController {

    private final VocabularyService vocabularyService;

    public VocabularyController(VocabularyService vocabularyService) {
        this.vocabularyService = vocabularyService;
    }

    @GetMapping("/categories")
    public List<VocabularyCategoryDto> getCategories() {
        return vocabularyService.getCategories();
    }

    @GetMapping("/categories/{id}")
    public VocabularyCategoryDto getCategory(@PathVariable Long id) {
        return vocabularyService.getCategoryById(id);
    }

    @GetMapping
    public List<VocabularyDto> getVocabulary(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String level
    ) {
        return vocabularyService.getVocabulary(categoryId, level);
    }

    @GetMapping("/{id}")
    public VocabularyDto getVocabularyById(@PathVariable Long id) {
        return vocabularyService.getVocabularyById(id);
    }
}
