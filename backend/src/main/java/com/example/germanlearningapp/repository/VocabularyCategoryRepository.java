package com.example.germanlearningapp.repository;

import com.example.germanlearningapp.entity.VocabularyCategory;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VocabularyCategoryRepository extends JpaRepository<VocabularyCategory, Long> {

    Optional<VocabularyCategory> findByName(String name);
}
