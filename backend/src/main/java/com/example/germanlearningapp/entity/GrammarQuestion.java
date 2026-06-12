package com.example.germanlearningapp.entity;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.util.ArrayList;
import java.util.List;

@Entity
public class GrammarQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "topic_id")
    private GrammarTopic topic;

    @Column(nullable = false, length = 500)
    private String question;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "grammar_question_options", joinColumns = @JoinColumn(name = "grammar_question_id"))
    @Column(name = "option_text", nullable = false)
    private List<String> options = new ArrayList<>();

    @Column(nullable = false)
    private Integer correctAnswerIndex;

    @Column(nullable = false, length = 1000)
    private String explanation;

    @Column(nullable = false)
    private String level;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public GrammarTopic getTopic() {
        return topic;
    }

    public void setTopic(GrammarTopic topic) {
        this.topic = topic;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public List<String> getOptions() {
        return options;
    }

    public void setOptions(List<String> options) {
        this.options = options;
    }

    public Integer getCorrectAnswerIndex() {
        return correctAnswerIndex;
    }

    public void setCorrectAnswerIndex(Integer correctAnswerIndex) {
        this.correctAnswerIndex = correctAnswerIndex;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }
}
