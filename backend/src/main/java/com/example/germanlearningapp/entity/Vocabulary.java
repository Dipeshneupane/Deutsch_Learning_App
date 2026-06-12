package com.example.germanlearningapp.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class Vocabulary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String german;

    @Column(nullable = false)
    private String english;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "category_id")
    private VocabularyCategory category;

    @Column(nullable = false)
    private String level;

    @Column(nullable = false, length = 500)
    private String exampleGerman;

    @Column(nullable = false, length = 500)
    private String exampleEnglish;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getGerman() {
        return german;
    }

    public void setGerman(String german) {
        this.german = german;
    }

    public String getEnglish() {
        return english;
    }

    public void setEnglish(String english) {
        this.english = english;
    }

    public VocabularyCategory getCategory() {
        return category;
    }

    public void setCategory(VocabularyCategory category) {
        this.category = category;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getExampleGerman() {
        return exampleGerman;
    }

    public void setExampleGerman(String exampleGerman) {
        this.exampleGerman = exampleGerman;
    }

    public String getExampleEnglish() {
        return exampleEnglish;
    }

    public void setExampleEnglish(String exampleEnglish) {
        this.exampleEnglish = exampleEnglish;
    }
}
