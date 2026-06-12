package com.example.germanlearningapp.repository;

import com.example.germanlearningapp.entity.GrammarTopic;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GrammarTopicRepository extends JpaRepository<GrammarTopic, Long> {

    List<GrammarTopic> findByLevelOrderByIdAsc(String level);

    Optional<GrammarTopic> findByTitle(String title);
}
