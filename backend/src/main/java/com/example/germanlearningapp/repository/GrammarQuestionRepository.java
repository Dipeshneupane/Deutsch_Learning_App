package com.example.germanlearningapp.repository;

import com.example.germanlearningapp.entity.GrammarQuestion;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GrammarQuestionRepository extends JpaRepository<GrammarQuestion, Long> {

    List<GrammarQuestion> findByTopicIdOrderByIdAsc(Long topicId);

    List<GrammarQuestion> findByLevelOrderByIdAsc(String level);

    List<GrammarQuestion> findByTopicIdAndLevelOrderByIdAsc(Long topicId, String level);

    List<GrammarQuestion> findByTopicIdAndQuestionOrderByIdAsc(Long topicId, String question);
}
