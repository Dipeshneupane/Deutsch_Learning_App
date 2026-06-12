package com.example.germanlearningapp.controller;

import com.example.germanlearningapp.dto.GrammarQuestionDto;
import com.example.germanlearningapp.dto.GrammarTopicDto;
import com.example.germanlearningapp.service.GrammarService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/grammar")
public class GrammarController {

    private final GrammarService grammarService;

    public GrammarController(GrammarService grammarService) {
        this.grammarService = grammarService;
    }

    @GetMapping("/topics")
    public List<GrammarTopicDto> getTopics(@RequestParam(required = false) String level) {
        return grammarService.getTopics(level);
    }

    @GetMapping("/topics/{id}")
    public GrammarTopicDto getTopic(@PathVariable Long id) {
        return grammarService.getTopicById(id);
    }

    @GetMapping("/questions")
    public List<GrammarQuestionDto> getQuestions(
            @RequestParam(required = false) Long topicId,
            @RequestParam(required = false) String level
    ) {
        return grammarService.getQuestions(topicId, level);
    }

    @GetMapping("/questions/{id}")
    public GrammarQuestionDto getQuestion(@PathVariable Long id) {
        return grammarService.getQuestionById(id);
    }
}
