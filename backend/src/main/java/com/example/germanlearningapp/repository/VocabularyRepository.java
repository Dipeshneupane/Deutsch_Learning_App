package com.example.germanlearningapp.repository;

import com.example.germanlearningapp.entity.Vocabulary;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {

    List<Vocabulary> findByCategoryIdOrderByGermanAsc(Long categoryId);

    List<Vocabulary> findByLevelOrderByGermanAsc(String level);

    List<Vocabulary> findByCategoryIdAndLevelOrderByGermanAsc(Long categoryId, String level);

    Optional<Vocabulary> findByGermanAndCategoryId(String german, Long categoryId);
}
