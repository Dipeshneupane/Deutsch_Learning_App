package com.example.germanlearningapp.seed;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import com.example.germanlearningapp.entity.GrammarQuestion;
import com.example.germanlearningapp.entity.GrammarTopic;
import com.example.germanlearningapp.entity.Vocabulary;
import com.example.germanlearningapp.entity.VocabularyCategory;
import com.example.germanlearningapp.repository.GrammarQuestionRepository;
import com.example.germanlearningapp.repository.GrammarTopicRepository;
import com.example.germanlearningapp.repository.VocabularyCategoryRepository;
import com.example.germanlearningapp.repository.VocabularyRepository;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.core.io.ClassPathResource;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataSeeder implements CommandLineRunner {

    private static final List<String> VOCABULARY_CATEGORY_RESOURCES = List.of(
            "seed/vocabulary-categories.csv",
            "seed/vocabulary-categories-extended.csv"
    );
    private static final List<String> VOCABULARY_ITEM_RESOURCES = List.of(
            "seed/vocabulary-items.csv",
            "seed/vocabulary-items-extended.csv"
    );

    private final VocabularyCategoryRepository vocabularyCategoryRepository;
    private final VocabularyRepository vocabularyRepository;
    private final GrammarTopicRepository grammarTopicRepository;
    private final GrammarQuestionRepository grammarQuestionRepository;

    public DataSeeder(
            VocabularyCategoryRepository vocabularyCategoryRepository,
            VocabularyRepository vocabularyRepository,
            GrammarTopicRepository grammarTopicRepository,
            GrammarQuestionRepository grammarQuestionRepository
    ) {
        this.vocabularyCategoryRepository = vocabularyCategoryRepository;
        this.vocabularyRepository = vocabularyRepository;
        this.grammarTopicRepository = grammarTopicRepository;
        this.grammarQuestionRepository = grammarQuestionRepository;
    }

    @Override
    public void run(String... args) {
        seedVocabulary();
        seedGrammar();
    }

    private void seedVocabulary() {
        Map<String, VocabularyCategory> categories = new LinkedHashMap<>();
        for (VocabularyCategorySeed categorySeed : loadVocabularyCategorySeeds()) {
            VocabularyCategory category = ensureCategory(
                    categorySeed.name(),
                    categorySeed.description(),
                    categorySeed.iconName()
            );
            categories.put(categorySeed.name(), category);
        }

        Set<String> seededVocabularyKeys = new java.util.HashSet<>();
        for (VocabularyItemSeed itemSeed : loadVocabularyItemSeeds()) {
            VocabularyCategory category = categories.get(itemSeed.categoryName());
            if (category == null) {
                throw new IllegalStateException("Missing category for vocabulary seed: " + itemSeed.categoryName());
            }

            seededVocabularyKeys.add(vocabularySeedKey(category.getId(), itemSeed.german()));

            Vocabulary vocabulary = vocabularyRepository
                    .findByGermanAndCategoryId(itemSeed.german(), category.getId())
                    .orElseGet(Vocabulary::new);

            vocabulary.setGerman(itemSeed.german());
            vocabulary.setEnglish(itemSeed.english());
            vocabulary.setCategory(category);
            vocabulary.setLevel(itemSeed.level());
            vocabulary.setExampleGerman(buildVocabularyExampleGerman(itemSeed.german()));
            vocabulary.setExampleEnglish(buildVocabularyExampleEnglish(itemSeed.english()));
            vocabularyRepository.save(vocabulary);
        }

        List<Vocabulary> obsoleteVocabulary = vocabularyRepository.findAll().stream()
                .filter(vocabulary -> !seededVocabularyKeys.contains(
                        vocabularySeedKey(vocabulary.getCategory().getId(), vocabulary.getGerman())
                ))
                .toList();
        if (!obsoleteVocabulary.isEmpty()) {
            vocabularyRepository.deleteAll(obsoleteVocabulary);
        }
    }

    private void seedGrammar() {
        Map<String, GrammarTopic> topics = new LinkedHashMap<>();
        topics.put("Articles: der, die, das", ensureTopic("Articles: der, die, das", "Choose the correct article for common beginner nouns.", "A1"));
        topics.put("Personal Pronouns", ensureTopic("Personal Pronouns", "Practice ich, du, er, sie, es, wir, ihr, sie.", "A1"));
        topics.put("Present Tense Verbs", ensureTopic("Present Tense Verbs", "Use regular and common irregular verbs in the present tense.", "A1"));
        topics.put("Sentence Structure", ensureTopic("Sentence Structure", "Build simple German sentences with the verb in the right place.", "A1"));
        topics.put("Nominative Case", ensureTopic("Nominative Case", "Spot the subject in simple German sentences.", "A1"));
        topics.put("Akkusative Case", ensureTopic("Akkusative Case", "Use direct objects and accusative articles correctly.", "A1"));
        topics.put("Modal Verbs", ensureTopic("Modal Verbs", "Practice koennen, muessen, wollen, and moegen.", "A1"));
        topics.put("Prepositions", ensureTopic("Prepositions", "Understand common place and time prepositions.", "A1"));
        topics.put("Question Words", ensureTopic("Question Words", "Choose the right question word for basic conversations.", "A1"));
        topics.put("Perfect Tense", ensureTopic("Perfect Tense", "Build beginner Perfekt sentences with haben and sein.", "A2"));
        topics.put("Dative Case", ensureTopic("Dative Case", "Use indirect objects and common dative forms in everyday German.", "A2"));
        topics.put("Separable Verbs", ensureTopic("Separable Verbs", "Practice common trennbare Verben in present and perfect contexts.", "A2"));
        topics.put("Reflexive Verbs", ensureTopic("Reflexive Verbs", "Use reflexive verbs like sich freuen and sich erinnern correctly.", "A2"));
        topics.put("Comparative & Superlative", ensureTopic("Comparative & Superlative", "Compare people and things with als and am ...sten.", "A2"));
        topics.put("Subordinate Clauses: weil and dass", ensureTopic("Subordinate Clauses: weil and dass", "Build simple subordinate clauses with verb-final word order.", "A2"));
        topics.put("Prateritum: haben and sein", ensureTopic("Prateritum: haben and sein", "Use war and hatte in common past-tense situations.", "A2"));
        topics.put("Two-Way Prepositions", ensureTopic("Two-Way Prepositions", "Choose between accusative and dative after common location prepositions.", "A2"));
        topics.put("Possessive Pronouns", ensureTopic("Possessive Pronouns", "Use mein, dein, sein, ihr, unser, and euer in context.", "A2"));
        topics.put("Infinitive with zu", ensureTopic("Infinitive with zu", "Connect verbs with zu plus infinitive in everyday German.", "A2"));
        topics.put("Imperative", ensureTopic("Imperative", "Give polite and informal instructions in German.", "A2"));
        topics.put("Relative Clauses", ensureTopic("Relative Clauses", "Connect ideas with relative pronouns like der, die, das, and prepositional forms.", "B1"));
        topics.put("Passive Voice", ensureTopic("Passive Voice", "Describe actions and processes with werden plus past participle.", "B1"));
        topics.put("Konjunktiv II", ensureTopic("Konjunktiv II", "Make polite requests, wishes, and unreal statements in everyday German.", "B1"));
        topics.put("Genitive Case", ensureTopic("Genitive Case", "Show possession and use common genitive prepositions like wegen and trotz.", "B1"));
        topics.put("Adjective Endings", ensureTopic("Adjective Endings", "Practice adjective endings after articles, possessives, and zero article.", "B1"));
        topics.put("Plusquamperfekt", ensureTopic("Plusquamperfekt", "Talk about actions that happened before another point in the past.", "B1"));
        topics.put("Futur I", ensureTopic("Futur I", "Use werden plus infinitive for future plans and simple assumptions.", "B1"));
        topics.put("Verbs with Prepositions", ensureTopic("Verbs with Prepositions", "Learn common verb-preposition combinations and their case patterns.", "B1"));
        topics.put("Infinitive Clauses: um/ohne/statt zu", ensureTopic("Infinitive Clauses: um/ohne/statt zu", "Express purpose, absence, and alternatives with advanced infinitive clauses.", "B1"));
        topics.put("Conditional Sentences with wenn", ensureTopic("Conditional Sentences with wenn", "Build real and simple unreal conditions with wenn clauses.", "B1"));

        seedTopicQuestions(topics.get("Articles: der, die, das"), List.of(
                question("Choose the correct article: ___ Tisch", List.of("der", "die", "das", "den"), 0, "Tisch is masculine, so it uses der."),
                question("Choose the correct article: ___ Lampe", List.of("der", "die", "das", "dem"), 1, "Lampe is feminine, so it uses die."),
                question("Choose the correct article: ___ Buch", List.of("der", "die", "das", "des"), 2, "Buch is neuter, so it uses das."),
                question("Which is correct?", List.of("die Apfel", "der Apfel", "das Apfel", "den Apfel"), 1, "Apfel is masculine in the nominative: der Apfel."),
                question("Which is correct?", List.of("das Auto", "die Auto", "der Auto", "dem Auto"), 0, "Auto is neuter, so das Auto is correct."),
                question("Choose the correct article: ___ Schule", List.of("das", "der", "die", "den"), 2, "Schule is feminine, so it uses die."),
                question("Choose the correct article: ___ Fenster", List.of("das", "die", "der", "dem"), 0, "Fenster is neuter, so it uses das."),
                question("Choose the correct article: ___ Freund", List.of("die", "das", "der", "den"), 2, "Freund is masculine, so it uses der."),
                question("Choose the correct article: ___ Stadt", List.of("der", "die", "das", "dem"), 1, "Stadt is feminine, so it uses die."),
                question("Choose the correct article: ___ Kind", List.of("der", "die", "das", "den"), 2, "Kind is neuter, so it uses das.")
        ));

        seedTopicQuestions(topics.get("Personal Pronouns"), List.of(
                question("___ bin muede.", List.of("Ich", "Du", "Wir", "Ihr"), 0, "Ich goes with bin."),
                question("Anna ist hier. ___ lernt Deutsch.", List.of("Er", "Sie", "Es", "Wir"), 1, "Anna is replaced by the pronoun sie."),
                question("Tom und ich wohnen in Berlin. ___ wohnen in Berlin.", List.of("Wir", "Sie", "Ihr", "Es"), 0, "Tom and I become wir."),
                question("Paul ist mein Bruder. ___ spielt Tennis.", List.of("Sie", "Es", "Er", "Ihr"), 2, "Paul is masculine, so the pronoun is er."),
                question("Lisa und Marie, ___ seid freundlich.", List.of("ihr", "wir", "sie", "du"), 0, "When speaking to Lisa and Marie directly, use ihr."),
                question("Das Kind ist klein. ___ spielt im Garten.", List.of("Er", "Sie", "Es", "Wir"), 2, "Kind is referred to with es in German."),
                question("Du und Max, ___ seid spaet.", List.of("wir", "ihr", "sie", "er"), 1, "For you plural, German uses ihr."),
                question("Meine Freunde kommen spaeter. ___ kommen um acht.", List.of("Sie", "Ihr", "Wir", "Es"), 0, "Friends in the third person plural use sie."),
                question("Maria und ich sind im Cafe. ___ trinken Tee.", List.of("Sie", "Es", "Wir", "Ihr"), 2, "Maria and I become wir."),
                question("Herr Becker, ___ sind sehr nett.", List.of("du", "ihr", "Sie", "er"), 2, "Formal you in German is Sie.")
        ));

        seedTopicQuestions(topics.get("Present Tense Verbs"), List.of(
                question("Ich ___ in Berlin.", List.of("wohne", "wohnst", "wohnt", "wohnen"), 0, "With ich, the verb wohnen becomes wohne."),
                question("Du ___ Deutsch.", List.of("lerne", "lernen", "lernst", "lernt"), 2, "With du, the verb takes the -st ending."),
                question("Er ___ Kaffee.", List.of("trinkst", "trinke", "trinkt", "trinken"), 2, "With er, the verb ends with -t."),
                question("Wir ___ heute viel.", List.of("arbeitet", "arbeite", "arbeiten", "arbeitest"), 2, "With wir, the infinitive form arbeiten is used."),
                question("Ihr ___ schnell.", List.of("lauft", "laufe", "laeuft", "laufen"), 0, "With ihr, the verb ends with -t."),
                question("Sie ___ morgen.", List.of("kommen", "kommt", "kommst", "komme"), 0, "Third person plural uses the infinitive form kommen."),
                question("Du ___ gern Musik.", List.of("hoerst", "hoert", "hoere", "hoeren"), 0, "With du, hoeren becomes hoerst."),
                question("Es ___ kalt.", List.of("sind", "seid", "ist", "bin"), 2, "The verb sein for es is ist."),
                question("Wir ___ ein Buch.", List.of("lesen", "liest", "lese", "liestet"), 0, "With wir, the verb is lesen."),
                question("Ich ___ nach Hause.", List.of("gehst", "gehen", "gehe", "geht"), 2, "With ich, gehen becomes gehe.")
        ));

        seedTopicQuestions(topics.get("Sentence Structure"), List.of(
                question("Choose the correct sentence.", List.of("Ich heute lerne Deutsch.", "Ich lerne heute Deutsch.", "Ich Deutsch lerne heute.", "Heute ich Deutsch lerne."), 1, "In a simple statement, the conjugated verb comes second: Ich lerne heute Deutsch."),
                question("Choose the correct sentence.", List.of("Morgen wir fahren nach Berlin.", "Wir morgen fahren nach Berlin.", "Wir fahren morgen nach Berlin.", "Fahren wir morgen nach Berlin."), 2, "In a normal statement, the verb stays in second position."),
                question("Choose the correct sentence.", List.of("Er trinkt am Morgen Kaffee.", "Er am Morgen trinkt Kaffee.", "Am Morgen Kaffee trinkt er.", "Kaffee er trinkt am Morgen."), 0, "Er trinkt am Morgen Kaffee follows standard word order."),
                question("If the sentence starts with 'Heute', what comes next?", List.of("The object", "The subject", "The conjugated verb", "An adjective"), 2, "German keeps the conjugated verb in second position."),
                question("Choose the correct sentence.", List.of("Im Park spielen die Kinder.", "Im Park die Kinder spielen.", "Die Kinder im Park spielen.", "Spielen die Kinder im Park."), 0, "Starting with a place puts the verb next: Im Park spielen die Kinder."),
                question("Choose the correct question.", List.of("Wo du wohnst?", "Wo wohnst du?", "Wo du wohnen?", "Wohnst wo du?"), 1, "In questions, the verb usually comes before the subject."),
                question("Choose the correct sentence.", List.of("Mein Bruder liest abends oft.", "Mein Bruder oft liest abends.", "Liest mein Bruder oft abends.", "Mein Bruder liest oft abends."), 3, "Mein Bruder liest oft abends is the most natural beginner order here."),
                question("Choose the correct sentence.", List.of("Heute ich bin muede.", "Heute bin ich muede.", "Ich heute bin muede.", "Bin heute ich muede."), 1, "When Heute starts the sentence, bin stays in second position."),
                question("What is true about German main clauses?", List.of("The verb is always last", "The verb is always first", "The conjugated verb is usually second", "The subject is always first"), 2, "The core beginner rule is that the conjugated verb is usually second."),
                question("Choose the correct sentence.", List.of("Nach der Arbeit ich gehe nach Hause.", "Nach der Arbeit gehe ich nach Hause.", "Ich nach der Arbeit gehe nach Hause.", "Gehe ich nach der Arbeit nach Hause."), 1, "Starting with a time phrase pushes the verb into second position.")
        ));

        seedTopicQuestions(topics.get("Nominative Case"), List.of(
                question("Which word is the subject? 'Der Hund spielt im Garten.'", List.of("Der Hund", "spielt", "im Garten", "Garten"), 0, "The nominative case marks the subject, and here the subject is Der Hund."),
                question("Choose the correct subject article: ___ Mann arbeitet hier.", List.of("Den", "Dem", "Der", "Des"), 2, "The subject is nominative masculine: der Mann."),
                question("Which sentence uses a nominative subject correctly?", List.of("Den Lehrer spricht.", "Der Lehrer spricht.", "Dem Lehrer spricht.", "Des Lehrer spricht."), 1, "The subject Lehrer must be nominative: der Lehrer."),
                question("In 'Die Frau liest ein Buch', which phrase is nominative?", List.of("ein Buch", "liest", "Die Frau", "Buch"), 2, "Die Frau is the subject, so it is nominative."),
                question("Choose the correct sentence.", List.of("Das Kind spielt.", "Den Kind spielt.", "Dem Kind spielt.", "Des Kind spielt."), 0, "Das Kind is the nominative subject."),
                question("Which article is nominative feminine?", List.of("die", "der", "das", "den"), 0, "The nominative feminine article is die."),
                question("Which article is nominative neuter?", List.of("den", "der", "das", "dem"), 2, "The nominative neuter article is das."),
                question("Choose the correct subject phrase.", List.of("die Schwester", "der Schwester", "den Schwester", "dem Schwester"), 0, "As the subject, Schwester needs the nominative form die Schwester."),
                question("Which sentence is correct?", List.of("Der Apfel ist rot.", "Den Apfel ist rot.", "Dem Apfel ist rot.", "Des Apfel ist rot."), 0, "Der Apfel is the nominative subject."),
                question("What does the nominative case usually mark?", List.of("The indirect object", "The direct object", "The subject", "Possession"), 2, "The nominative case is mainly used for the subject.")
        ));

        seedTopicQuestions(topics.get("Akkusative Case"), List.of(
                question("Ich kaufe ___ Apfel.", List.of("der", "dem", "den", "des"), 2, "Apfel is the direct object, so masculine changes to den in the accusative."),
                question("Wir haben ___ Buch.", List.of("das", "dem", "des", "der"), 0, "Neuter articles stay das in the accusative."),
                question("Sie sieht ___ Frau.", List.of("die", "der", "den", "dem"), 0, "Feminine articles stay die in the accusative."),
                question("Er trinkt ___ Kaffee.", List.of("der", "den", "dem", "des"), 1, "Kaffee is masculine and a direct object, so it becomes den Kaffee."),
                question("Choose the correct sentence.", List.of("Ich sehe der Hund.", "Ich sehe den Hund.", "Ich sehe dem Hund.", "Ich sehe des Hund."), 1, "Hund is a masculine direct object, so it uses den."),
                question("Which article changes in the accusative singular?", List.of("die", "das", "der masculine", "plural die"), 2, "Only the masculine singular definite article changes from der to den."),
                question("Sie braucht ___ Tasche.", List.of("den", "das", "die", "dem"), 2, "Tasche is feminine, so the accusative remains die Tasche."),
                question("Ich nehme ___ Stift.", List.of("den", "der", "das", "die"), 0, "Stift is masculine, so it becomes den Stift in the accusative."),
                question("Wir lernen ___ Wort.", List.of("die", "das", "der", "dem"), 1, "Wort is neuter, so the accusative form is das Wort."),
                question("What does the accusative case usually mark?", List.of("The subject", "The direct object", "Possession", "The predicate"), 1, "The accusative case usually marks the direct object.")
        ));

        seedTopicQuestions(topics.get("Modal Verbs"), List.of(
                question("Ich ___ Deutsch sprechen.", List.of("kann", "kannst", "koennen", "musst"), 0, "With ich, koennen becomes kann."),
                question("Du ___ heute arbeiten.", List.of("muss", "musst", "muessen", "muest"), 1, "With du, muessen becomes musst."),
                question("Wir ___ ins Kino gehen.", List.of("will", "wollen", "wollt", "willst"), 1, "With wir, wollen stays wollen."),
                question("Er ___ einen Kaffee.", List.of("mag", "moegen", "magst", "moegt"), 0, "With er, moegen becomes mag."),
                question("Ihr ___ leise sein.", List.of("kann", "koennt", "kannst", "koennen"), 1, "With ihr, koennen becomes koennt."),
                question("Choose the correct sentence.", List.of("Ich kann schwimmen.", "Ich schwimmen kann.", "Kann ich schwimmen.", "Ich kannen schwimmen."), 0, "The modal verb is conjugated and the second verb goes to the end."),
                question("Sie ___ frueh aufstehen.", List.of("muessen", "muesst", "muss", "muesen"), 0, "Third person plural uses muessen."),
                question("Du ___ heute nicht kommen.", List.of("will", "willst", "wollen", "wollt"), 1, "With du, wollen becomes willst."),
                question("Wir ___ Deutsch lernen.", List.of("moegen", "moegt", "mag", "magst"), 0, "With wir, the modal verb is moegen."),
                question("What happens to the second verb after a modal verb?", List.of("It disappears", "It stays unconjugated at the end", "It moves to the front", "It becomes a noun"), 1, "The second verb stays in the infinitive and goes to the end.")
        ));

        seedTopicQuestions(topics.get("Prepositions"), List.of(
                question("Ich bin ___ dem Haus.", List.of("in", "auf", "unter", "an"), 0, "In is the most natural beginner choice here: in dem Haus."),
                question("Das Buch liegt ___ dem Tisch.", List.of("unter", "auf", "zwischen", "aus"), 1, "Objects resting on a surface use auf."),
                question("Wir fahren ___ Berlin.", List.of("nach", "bei", "mit", "ohne"), 0, "Cities and countries without articles often use nach."),
                question("Der Hund ist ___ dem Tisch.", List.of("unter", "durch", "gegen", "zu"), 0, "Under the table is unter dem Tisch."),
                question("Ich komme ___ der Schule.", List.of("aus", "an", "auf", "neben"), 0, "To come from a place uses aus."),
                question("Sie sitzt ___ ihrer Freundin.", List.of("mit", "zwischen", "bei", "gegen"), 2, "Being at or by someone often uses bei."),
                question("Das Bild haengt ___ der Wand.", List.of("an", "zu", "durch", "seit"), 0, "Pictures hang an der Wand."),
                question("Wir gehen ___ den Park.", List.of("gegen", "durch", "ohne", "fuer"), 1, "Moving through a place uses durch."),
                question("Ich lerne Deutsch ___ zwei Monaten.", List.of("seit", "gegen", "durch", "zu"), 0, "Since a starting point in time uses seit."),
                question("Choose the best preposition: Kaffee ___ Milch", List.of("ohne", "durch", "an", "zwischen"), 0, "Without milk is ohne Milch.")
        ));

        seedTopicQuestions(topics.get("Question Words"), List.of(
                question("___ heisst du?", List.of("Wer", "Wo", "Wie", "Wann"), 2, "To ask for a name, German uses Wie heisst du?"),
                question("___ wohnst du?", List.of("Wo", "Was", "Wie", "Warum"), 0, "Wo asks about location."),
                question("___ kommst du aus?", List.of("Wann", "Woher", "Wie", "Wohin"), 1, "Woher asks where someone comes from."),
                question("___ kostet das?", List.of("Was", "Wie viel", "Wer", "Wann"), 1, "Price questions use Wie viel kostet das?"),
                question("___ ist dein Lehrer?", List.of("Wer", "Wie", "Wo", "Warum"), 0, "Wer asks about a person."),
                question("___ lernst du Deutsch?", List.of("Warum", "Wann", "Wohin", "Wie"), 0, "Warum asks for a reason."),
                question("___ faehrst du nach Hause?", List.of("Wann", "Wo", "Wer", "Wie alt"), 0, "Wann asks about time."),
                question("___ alt bist du?", List.of("Was", "Wie", "Wer", "Wann"), 1, "Age questions use Wie alt bist du?"),
                question("___ machst du am Wochenende?", List.of("Was", "Woher", "Wohin", "Warum"), 0, "Was asks what someone does."),
                question("___ gehst du jetzt?", List.of("Wo", "Wohin", "Woher", "Wer"), 1, "Wohin asks where someone is going.")
        ));

        seedTopicQuestions(topics.get("Perfect Tense"), List.of(
                question("Ich ___ heute Deutsch gelernt.", List.of("habe", "bin", "hat", "bist"), 0, "Most regular verbs use haben in the Perfekt tense."),
                question("Wir ___ nach Berlin gefahren.", List.of("haben", "sind", "seid", "ist"), 1, "Movement from one place to another often uses sein."),
                question("Sie ___ einen Kuchen gemacht.", List.of("ist", "sind", "haben", "hat"), 3, "With sie singular, machen uses hat gemacht."),
                question("Er ___ gestern zu Hause geblieben.", List.of("ist", "hat", "seid", "haben"), 0, "Bleiben usually forms the Perfekt with sein."),
                question("Du ___ das Buch gelesen.", List.of("bist", "hast", "hat", "haben"), 1, "Lesen takes haben, so du hast gelesen."),
                question("Choose the correct sentence.", List.of("Ich habe gespielt.", "Ich bin gespielt.", "Ich habe spielen.", "Ich bin spielen."), 0, "Played is formed with haben plus the participle: habe gespielt."),
                question("Wir ___ frueh angekommen.", List.of("haben", "sind", "hat", "bist"), 1, "Ankommen uses sein in the Perfekt tense."),
                question("Maria ___ Kaffee getrunken.", List.of("bin", "ist", "hat", "haben"), 2, "Trinken uses haben, so Maria hat getrunken."),
                question("What do you need for Perfekt?", List.of("A modal verb only", "A helping verb and a past participle", "Only the infinitive", "A future marker"), 1, "Perfekt is built with a helping verb plus a past participle."),
                question("Which helping verb often goes with movement verbs?", List.of("haben", "sein", "werden", "koennen"), 1, "Many movement verbs commonly use sein in the Perfekt tense.")
        ));

        seedTopicQuestions(topics.get("Dative Case"), List.of(
                question("Ich helfe ___ Mann.", List.of("der", "den", "dem", "des"), 2, "Helfen takes the dative, so the correct form is dem Mann."),
                question("Wir danken ___ Lehrerin.", List.of("die", "der", "den", "dem"), 1, "Danken also takes the dative: der Lehrerin."),
                question("Ich gebe ___ Kind ein Buch.", List.of("das", "dem", "den", "des"), 1, "The receiver is in the dative case: dem Kind."),
                question("Which article is dative feminine?", List.of("die", "der", "das", "den"), 1, "The dative feminine article is der."),
                question("Which article is dative plural?", List.of("die", "den", "dem", "der"), 1, "In the plural dative, the article is den."),
                question("Ich schreibe ___ Freunden eine Nachricht.", List.of("die", "den", "der", "dem"), 1, "Freunden is plural dative, so it takes den."),
                question("Er antwortet ___ Frau.", List.of("die", "der", "dem", "den"), 1, "Antworten uses the dative: der Frau."),
                question("Choose the correct sentence.", List.of("Ich gebe den Kind das Heft.", "Ich gebe dem Kind das Heft.", "Ich gebe das Kind dem Heft.", "Ich gebe der Kind das Heft."), 1, "The indirect object Kind must be dative: dem Kind."),
                question("Which verb often takes a dative object?", List.of("sehen", "besuchen", "helfen", "kaufen"), 2, "Helfen is a common dative verb."),
                question("What does the dative often mark?", List.of("The subject", "The direct object", "The indirect object", "Possession"), 2, "The dative often marks the indirect object.")
        ));

        seedTopicQuestions(topics.get("Separable Verbs"), List.of(
                question("Ich ___ morgen um sechs ___.", List.of("stehe ... auf", "aufstehe ...", "stehe auf ...", "auf ... stehe"), 0, "In a main clause, the prefix moves to the end: Ich stehe morgen um sechs auf."),
                question("Wir ___ den Mantel ___.", List.of("ziehen ... an", "anziehen ...", "an ... ziehen", "ziehen an ..."), 0, "Anziehen separates in the present tense: Wir ziehen den Mantel an."),
                question("Er ___ seine Mutter ___.", List.of("ruft ... an", "anruft ...", "ruft an ...", "an ... ruft"), 0, "Anrufen becomes ruft ... an in a main clause."),
                question("Which is correct?", List.of("Ich einkaufe heute.", "Ich kaufe heute ein.", "Ich ein kaufe heute.", "Ich heute einkaufe."), 1, "Einkaufen separates: Ich kaufe heute ein."),
                question("In a separable verb sentence, where does the prefix go?", List.of("Always before the subject", "Always after the noun", "Usually to the end of the clause", "It disappears"), 2, "The separable prefix usually moves to the end of the main clause."),
                question("Sie ___ um acht Uhr ___ .", List.of("faengt ... an", "anfaengt ...", "faengt an ...", "an ... faengt"), 0, "Anfangen separates: Sie faengt um acht Uhr an."),
                question("Choose the correct sentence.", List.of("Wir machen die Tuer auf.", "Wir aufmachen die Tuer.", "Wir machen auf die Tuer.", "Wir auf die Tuer machen."), 0, "Aufmachen becomes machen ... auf."),
                question("What is the infinitive of 'Er kommt spaet zurueck'?", List.of("kommzurueck", "zurueckkommen", "kommenzurueck", "zurueck zu kommen"), 1, "The infinitive form is zurueckkommen."),
                question("Du ___ bitte das Licht ___ .", List.of("machst ... aus", "ausmachst ...", "machst aus ...", "aus ... machst"), 0, "Ausmachen separates: Du machst bitte das Licht aus."),
                question("Choose the correct Perfekt form.", List.of("Ich habe angerufen.", "Ich habe gerufen an.", "Ich bin angerufen.", "Ich habe anrufen."), 0, "In the Perfekt tense, the separable verb comes back together in the participle: angerufen.")
        ));

        seedTopicQuestions(topics.get("Reflexive Verbs"), List.of(
                question("Ich ___ morgens schnell.", List.of("wasche mich", "wasche michs", "mich wasche", "wascht mich"), 0, "With ich, the reflexive form is ich wasche mich."),
                question("Du ___ auf die Reise.", List.of("freust dich", "freut dich", "dich freust", "freust dir"), 0, "Sich freuen becomes du freust dich."),
                question("Wir ___ an den Termin.", List.of("erinnern uns", "erinnern euch", "uns erinnern", "erinnert uns"), 0, "With wir, use uns: Wir erinnern uns."),
                question("Choose the correct sentence.", List.of("Er interessiert sich fuer Musik.", "Er interessiert ihn fuer Musik.", "Er sich interessiert fuer Musik.", "Er interessiert fuer sich Musik."), 0, "The correct reflexive construction is interessiert sich fuer."),
                question("What reflexive pronoun goes with ihr?", List.of("mich", "dich", "uns", "euch"), 3, "The reflexive pronoun for ihr is euch."),
                question("Sie ___ jeden Tag schminken.", List.of("muss sich", "muss mich", "muss euch", "muss dir"), 0, "With sie singular, use sich: Sie muss sich schminken."),
                question("Which verb is commonly reflexive?", List.of("bezahlen", "duschen", "kaufen", "wohnen"), 1, "Sich duschen is a common reflexive verb."),
                question("Ich ___ nach der Arbeit aus.", List.of("ruhe mich", "ruhe michs", "mich ruhe", "ruht mich"), 0, "Sich ausruhen with ich becomes ich ruhe mich aus."),
                question("Choose the correct sentence.", List.of("Wir treffen uns um sechs.", "Wir treffen euch um sechs.", "Wir uns treffen um sechs.", "Wir treffen sich um sechs."), 0, "With wir, the correct reflexive pronoun is uns."),
                question("Why do reflexive verbs need a reflexive pronoun?", List.of("To mark the action relates back to the subject", "To change tense", "To make the sentence plural", "To form the passive"), 0, "The pronoun shows the action relates back to the subject.")
        ));

        seedTopicQuestions(topics.get("Comparative & Superlative"), List.of(
                question("Paul ist ___ als Tim.", List.of("groesser", "am groessten", "gross", "so groessten"), 0, "Comparisons with als use the comparative: groesser."),
                question("Das ist ___ Film heute.", List.of("interessanter", "am interessantesten", "interessant", "interessanter als"), 1, "For the highest degree, German uses am ...sten."),
                question("Meine Schwester ist ___ ich.", List.of("junger als", "am juengsten", "jungster als", "so juenger"), 0, "Comparative plus als is correct: juenger als."),
                question("Which is the superlative of schnell?", List.of("schneller", "am schnellsten", "so schnell", "schnellest"), 1, "The superlative is am schnellsten."),
                question("Choose the correct sentence.", List.of("Der Winter ist kalt als der Herbst.", "Der Winter ist kaelter als der Herbst.", "Der Winter ist am kaelter als der Herbst.", "Der Winter ist kaeltesten als der Herbst."), 1, "Kaelter als is the correct comparative form."),
                question("This cake is the best.", List.of("Dieser Kuchen ist besser.", "Dieser Kuchen ist am besten.", "Dieser Kuchen ist bester als.", "Dieser Kuchen ist guter."), 1, "The superlative of gut is am besten."),
                question("Which word often follows a comparative?", List.of("weil", "und", "als", "zu"), 2, "Comparatives are often followed by als."),
                question("Anna lernt ___ als Max.", List.of("fleiessiger", "am fleissigsten", "fleiessigsten", "so fleissig"), 0, "For a direct comparison, use the comparative: fleissiger als."),
                question("Which is correct?", List.of("Heute ist es am waermsten.", "Heute ist es waermer als.", "Heute ist es warmsten.", "Heute ist es am waermer."), 0, "The superlative form is am waermsten."),
                question("What does the superlative express?", List.of("Similarity", "The highest degree", "Past time", "Possession"), 1, "The superlative expresses the highest degree.")
        ));

        seedTopicQuestions(topics.get("Subordinate Clauses: weil and dass"), List.of(
                question("Ich bleibe zu Hause, weil ich krank ___.", List.of("bin", "bist", "ist", "sein"), 0, "In a weil clause, the verb goes to the end: weil ich krank bin."),
                question("Sie sagt, dass sie morgen ___.", List.of("kommt", "kommen", "kommst", "kommt morgen"), 0, "In a dass clause, the verb goes to the end: dass sie morgen kommt."),
                question("Which is correct?", List.of("Weil es regnet, ich bleibe zu Hause.", "Weil es regnet, bleibe ich zu Hause.", "Weil es regnet, ich zu Hause bleibe.", "Weil regnet es, bleibe ich zu Hause."), 1, "The subordinate clause sends the main verb of the main clause to second position: bleibe ich."),
                question("What happens to the verb in a weil clause?", List.of("It disappears", "It moves to the end", "It stays first", "It becomes infinitive only"), 1, "In subordinate clauses with weil, the conjugated verb moves to the end."),
                question("Er weiss, dass wir heute spaet ___.", List.of("kommen", "kommen wir", "kommst", "kommt"), 0, "In the dass clause, the verb comes last: dass wir heute spaet kommen."),
                question("Choose the correct sentence.", List.of("Ich lerne Deutsch, weil ich in Berlin wohne.", "Ich lerne Deutsch, weil wohne ich in Berlin.", "Ich lerne Deutsch, weil ich wohne in Berlin.", "Ich lerne Deutsch, weil in Berlin ich wohne."), 0, "The subordinate clause needs verb-final order: weil ich in Berlin wohne."),
                question("Sie freut sich, dass ihr Freund heute ___.", List.of("anruft", "ruft an", "anrufen", "rufen an"), 0, "Even with a separable verb, the full form stays together at the end in a subordinate clause: anruft."),
                question("Which conjunction gives a reason?", List.of("dass", "weil", "als", "oder"), 1, "Weil introduces a reason."),
                question("Which conjunction introduces reported content?", List.of("dass", "weil", "aber", "denn"), 0, "Dass introduces content or reported statements."),
                question("What is true after a subordinate clause comes first?", List.of("The verb in the main clause stays second", "The subject must disappear", "The noun becomes plural", "The sentence ends immediately"), 0, "After the subordinate clause, the main clause still keeps the verb in second position.")
        ));

        seedTopicQuestions(topics.get("Prateritum: haben and sein"), List.of(
                question("Gestern ___ ich sehr muede.", List.of("war", "bin", "hatte", "ist"), 0, "The simple past of sein with ich is war."),
                question("Wir ___ keine Zeit.", List.of("waren", "hatten", "haben", "seid"), 1, "The simple past of haben with wir is hatten."),
                question("Du ___ gestern krank.", List.of("warst", "hattest", "bist", "war"), 0, "The simple past of sein with du is warst."),
                question("Sie ___ viel Arbeit.", List.of("war", "hatte", "hat", "waren"), 1, "For possession in the past, use hatte."),
                question("Which is the Prateritum of sein for er?", List.of("war", "ist", "hatte", "waere"), 0, "The correct form is war."),
                question("Which is the Prateritum of haben for ihr?", List.of("habt", "hattet", "haben", "hatten"), 1, "The simple past with ihr is hattet."),
                question("Choose the correct sentence.", List.of("Frueher war ich in Bonn.", "Frueher bin ich in Bonn.", "Frueher hatte ich in Bonn.", "Frueher ich war in Bonn."), 0, "War is the correct simple past form here."),
                question("Er ___ gestern keine Lust.", List.of("war", "hatte", "ist", "habt"), 1, "To say he had no desire, use hatte."),
                question("What are the Prateritum forms often used in spoken German?", List.of("Only modal verbs", "Only regular verbs", "Especially haben and sein", "No verbs at all"), 2, "Haben and sein are often used in the simple past even in spoken German."),
                question("Maria und Tom ___ gestern zu Hause.", List.of("waren", "hatten", "sind", "seid"), 0, "The simple past of sein for Maria und Tom is waren.")
        ));

        seedTopicQuestions(topics.get("Two-Way Prepositions"), List.of(
                question("Das Buch liegt ___ Tisch.", List.of("auf dem", "auf den", "in den", "an den"), 0, "A static location takes the dative: auf dem Tisch."),
                question("Ich lege das Buch ___ Tisch.", List.of("auf dem", "auf den", "an dem", "in dem"), 1, "A direction or movement takes the accusative: auf den Tisch."),
                question("Wir sitzen ___ Garten.", List.of("in den", "im", "auf den", "unter den"), 1, "A static location takes the dative: im Garten."),
                question("Er geht ___ Garten.", List.of("im", "in den", "an dem", "unter dem"), 1, "Movement into something takes the accusative: in den Garten."),
                question("The cat is under the chair.", List.of("Die Katze ist unter dem Stuhl.", "Die Katze ist unter den Stuhl.", "Die Katze geht unter dem Stuhl.", "Die Katze legt unter den Stuhl."), 0, "Static location with unter uses the dative."),
                question("She hangs the picture on the wall.", List.of("Sie haengt das Bild an der Wand.", "Sie haengt das Bild an die Wand.", "Sie ist an der Wand das Bild.", "Sie haengt an der Wand das Bild."), 1, "Movement toward the wall takes the accusative: an die Wand."),
                question("What decides between dative and accusative with two-way prepositions?", List.of("Plural or singular only", "Whether there is location or movement", "Whether the noun is long", "Whether the sentence is a question"), 1, "Location takes dative, movement toward a destination takes accusative."),
                question("The shoes are in the box.", List.of("Die Schuhe sind in der Kiste.", "Die Schuhe sind in die Kiste.", "Die Schuhe gehen in der Kiste.", "Die Schuhe legen in die Kiste."), 0, "Static location uses the dative."),
                question("We put the chairs next to the table.", List.of("Wir stellen die Stuehle neben den Tisch.", "Wir stellen die Stuehle neben dem Tisch.", "Wir sind neben den Tisch.", "Wir sitzen neben den Tisch."), 0, "Placing something somewhere uses movement, so accusative is correct."),
                question("Choose the correct sentence.", List.of("Ich stehe vor dem Haus.", "Ich gehe vor dem Haus.", "Ich lege vor dem Haus.", "Ich fahre vor dem Haus hinein."), 0, "Static position uses the dative: vor dem Haus.")
        ));

        seedTopicQuestions(topics.get("Possessive Pronouns"), List.of(
                question("Das ist ___ Buch.", List.of("mein", "meine", "meinen", "meinem"), 0, "Buch is neuter in the nominative, so mein Buch is correct."),
                question("Ist das ___ Tasche, Anna?", List.of("dein", "deine", "deinen", "deinem"), 1, "Tasche is feminine, so use deine Tasche."),
                question("Paul sucht ___ Schluessel.", List.of("sein", "seine", "seinen", "seinem"), 2, "Schluessel is masculine accusative here, so seinen is correct."),
                question("Wir besuchen ___ Eltern.", List.of("unser", "unsere", "unseren", "unserem"), 1, "Eltern is plural, so use unsere Eltern here."),
                question("Habt ihr ___ Hausaufgaben?", List.of("euer", "eure", "euren", "eurem"), 1, "Hausaufgaben is plural, so eure is the right form."),
                question("Maria liebt ___ Hund.", List.of("ihr", "ihre", "ihren", "ihrem"), 2, "Hund is masculine accusative after liebt, so ihren is correct."),
                question("Choose the correct sentence.", List.of("Das ist meine Bruder.", "Das ist mein Bruder.", "Das ist meinen Bruder.", "Das ist meinem Bruder."), 1, "Bruder is masculine nominative here, so mein Bruder is correct."),
                question("Which possessive pronoun matches wir?", List.of("euer", "unser", "sein", "ihr"), 1, "Wir uses unser."),
                question("Which is correct?", List.of("Sie trinkt aus ihrem Glas.", "Sie trinkt aus ihr Glas.", "Sie trinkt aus ihren Glas.", "Sie trinkt aus ihre Glas."), 0, "After aus, use the dative: ihrem Glas."),
                question("What do possessive pronouns show?", List.of("Past time", "Comparison", "Ownership or belonging", "Negation"), 2, "Possessive pronouns show ownership or belonging.")
        ));

        seedTopicQuestions(topics.get("Infinitive with zu"), List.of(
                question("Ich versuche, Deutsch ___ .", List.of("lernen", "zu lernen", "gelernt", "lerne"), 1, "After versuchen, use zu plus infinitive: zu lernen."),
                question("Er hofft, morgen frueh ___ .", List.of("kommen", "zu kommen", "kommt", "gekommen"), 1, "Hoffen can be followed by zu plus infinitive: zu kommen."),
                question("Which is correct?", List.of("Wir planen, am Wochenende zu reisen.", "Wir planen, am Wochenende reisen.", "Wir planen, zu am Wochenende reisen.", "Wir planen, am Wochenende gereist."), 0, "Planen is followed by zu plus infinitive."),
                question("Sie hat vergessen, das Fenster ___ .", List.of("schliessen", "zu schliessen", "schliesst", "geschlossen"), 1, "Vergessen often takes zu plus infinitive."),
                question("After many verbs like versuchen or planen, what comes next?", List.of("Only a noun", "Zu plus infinitive", "A past participle only", "Nothing"), 1, "Many such verbs are followed by zu plus infinitive."),
                question("Ich habe keine Lust, heute ___ .", List.of("arbeiten", "zu arbeiten", "arbeite", "gearbeitet"), 1, "Keine Lust haben is often followed by zu plus infinitive."),
                question("Choose the correct sentence.", List.of("Sie beginnt, zu lachen.", "Sie beginnt, lachen.", "Sie beginnt, gelacht.", "Sie beginnt, lacht."), 0, "Beginnen can be followed by zu plus infinitive."),
                question("Wir haben vor, nach Hamburg ___ .", List.of("fahren", "zu fahren", "gefahren", "fahrt"), 1, "Vorhaben takes zu plus infinitive here."),
                question("Er braucht Zeit, um die Aufgabe ___ .", List.of("machen", "zu machen", "gemacht", "macht"), 1, "In this sentence, zu plus infinitive is needed."),
                question("What is true about the infinitive in these structures?", List.of("It is conjugated", "It usually stays unconjugated", "It must be plural", "It becomes an adjective"), 1, "The infinitive stays unconjugated after zu.")
        ));

        seedTopicQuestions(topics.get("Imperative"), List.of(
                question("___ bitte leise!", List.of("Sei", "Bist", "Sein", "Seid"), 0, "The informal singular imperative of sein is sei."),
                question("___ das Fenster zu!", List.of("Macht", "Mach", "Machen", "Machst"), 1, "The informal singular imperative is mach."),
                question("Which is the polite imperative?", List.of("Geh!", "Geht!", "Gehen Sie!", "Gehst du!"), 2, "The polite imperative uses the infinitive plus Sie: Gehen Sie!"),
                question("You are speaking to several friends. Which is correct?", List.of("Kommt herein!", "Komm herein!", "Kommen Sie herein!", "Kommt ihr herein!"), 0, "The plural informal imperative is kommt herein."),
                question("Choose the correct sentence.", List.of("Bitte warten Sie hier.", "Bitte Sie warten hier.", "Bitte wartest Sie hier.", "Bitte warte Sie hier."), 0, "The polite imperative is warten Sie."),
                question("What is the informal singular imperative of lesen?", List.of("Lese!", "Lies!", "Lesen!", "Liest!"), 1, "The correct imperative form is lies."),
                question("Which sign is correct?", List.of("Nicht rauchst!", "Rauche nicht!", "Nicht rauchen!", "Du nicht rauchst!"), 2, "Signs often use the infinitive form: Nicht rauchen!"),
                question("Choose the best classroom instruction.", List.of("Oeffnet eure Buecher.", "Ihr oeffnet eure Buecher.", "Oeffnen Sie eure Buecher.", "Du oeffnest eure Buecher."), 0, "For several learners, the plural imperative Oeffnet is correct."),
                question("What word is often added to make the imperative friendlier?", List.of("gestern", "bitte", "schon", "dann"), 1, "Bitte often makes an instruction sound friendlier."),
                question("Which is correct for a close friend?", List.of("Nimm Platz!", "Nehmen Sie Platz!", "Nehmt Platz!", "Du nimmst Platz!"), 0, "For one close friend, use the singular imperative: Nimm Platz!")
        ));

        seedTopicQuestions(topics.get("Relative Clauses"), relativeClauseQuestions());
        seedTopicQuestions(topics.get("Passive Voice"), passiveVoiceQuestions());
        seedTopicQuestions(topics.get("Konjunktiv II"), konjunktivTwoQuestions());
        seedTopicQuestions(topics.get("Genitive Case"), genitiveCaseQuestions());
        seedTopicQuestions(topics.get("Adjective Endings"), adjectiveEndingQuestions());
        seedTopicQuestions(topics.get("Plusquamperfekt"), plusquamperfektQuestions());
        seedTopicQuestions(topics.get("Futur I"), futurOneQuestions());
        seedTopicQuestions(topics.get("Verbs with Prepositions"), verbPrepositionQuestions());
        seedTopicQuestions(topics.get("Infinitive Clauses: um/ohne/statt zu"), infinitiveClauseQuestions());
        seedTopicQuestions(topics.get("Conditional Sentences with wenn"), wennClauseQuestions());
    }

    private List<QuestionSeed> relativeClauseQuestions() {
        return List.of(
                question("Das ist der Mann, ___ in Berlin wohnt.", List.of("der", "den", "dem", "des"), 0, "The relative pronoun matches Mann as the subject inside the relative clause: der."),
                question("Das ist die Frau, ___ ich gestern getroffen habe.", List.of("die", "der", "deren", "das"), 0, "The woman is the direct object in the relative clause, so use die."),
                question("Das ist das Buch, ___ auf dem Tisch liegt.", List.of("das", "dem", "den", "deren"), 0, "Buch is neuter and the subject of the relative clause, so use das."),
                question("Die Kinder, ___ im Garten spielen, sind meine Nachbarn.", List.of("die", "den", "deren", "das"), 0, "Children is plural and the subject of the relative clause, so the pronoun is die."),
                question("Ich kenne den Lehrer, ___ du sehr magst.", List.of("der", "den", "dem", "des"), 1, "Lehrer is the direct object inside the relative clause, so use den."),
                question("Das ist die Kollegin, mit ___ ich arbeite.", List.of("die", "der", "den", "dem"), 1, "After mit, the relative pronoun is in the dative: mit der."),
                question("Das ist das Haus, in ___ wir wohnen.", List.of("das", "dem", "den", "des"), 1, "After in with a static location, use the dative: in dem."),
                question("Where does the conjugated verb usually go in a relative clause?", List.of("In first position", "In second position", "At the end", "Before the pronoun"), 2, "A relative clause is a subordinate clause, so the conjugated verb goes to the end."),
                question("Which is correct?", List.of("Das ist der Film, den ich sehen will.", "Das ist der Film, der ich sehen will.", "Das ist der Film, dem ich sehen will.", "Das ist der Film, des ich sehen will."), 0, "Film is the direct object of sehen, so den is correct."),
                question("Which relative pronoun matches a masculine noun in the nominative?", List.of("der", "den", "dem", "des"), 0, "For a masculine noun functioning as the subject, use der.")
        );
    }

    private List<QuestionSeed> passiveVoiceQuestions() {
        return List.of(
                question("Das Auto ___ repariert.", List.of("wird", "wurde", "ist", "hat"), 0, "The present passive uses werden plus past participle: wird repariert."),
                question("Die Briefe ___ heute geschrieben.", List.of("werden", "wird", "ist", "hat"), 0, "The plural subject takes werden in the present passive."),
                question("Die Tuer ___ jeden Morgen geoeffnet.", List.of("wird", "werden", "ist", "hat"), 0, "A singular subject in the present passive takes wird."),
                question("What do you need to build the present passive?", List.of("Sein plus adjective", "Werden plus past participle", "Haben plus infinitive", "Only a modal verb"), 1, "The standard present passive is formed with werden plus a past participle."),
                question("Das Essen ___ von meiner Mutter gekocht.", List.of("wird", "hat", "ist", "werden"), 0, "The doer can be added with von, but the passive verb is still wird gekocht."),
                question("Die Zimmer ___ jeden Tag gereinigt.", List.of("werden", "wird", "ist", "hat"), 0, "Zimmer is plural, so use werden gereinigt."),
                question("Which sentence is passive?", List.of("Der Mechaniker repariert das Fahrrad.", "Das Fahrrad wird repariert.", "Der Mechaniker wird das Fahrrad.", "Das Fahrrad repariert den Mechaniker."), 1, "The passive sentence focuses on the object becoming the subject: Das Fahrrad wird repariert."),
                question("In the passive voice, what is usually in focus?", List.of("The person who does the action", "The action or result", "The article only", "The time expression only"), 1, "The passive voice typically focuses on the action or the affected thing, not the doer."),
                question("Der Termin ___ auf morgen verschoben.", List.of("wird", "werden", "ist", "hat"), 0, "A singular noun takes wird: Der Termin wird verschoben."),
                question("Which word often introduces the doer in a passive sentence?", List.of("mit", "von", "nach", "zu"), 1, "The doer is commonly introduced with von, as in von meiner Mutter.")
        );
    }

    private List<QuestionSeed> konjunktivTwoQuestions() {
        return List.of(
                question("Ich ___ gern mehr Zeit.", List.of("haette", "habe", "hatte", "haben"), 0, "For a wish or polite expression, use the Konjunktiv II form haette."),
                question("___ Sie mir bitte helfen?", List.of("Koennten", "Konnten", "Kann", "Koennen"), 0, "Koennten is the polite Konjunktiv II form for a request."),
                question("Wenn ich mehr Geld haette, ___ ich mehr reisen.", List.of("werde", "wuerde", "bin", "habe"), 1, "An unreal idea is often expressed with wuerde plus infinitive."),
                question("Ich wuenschte, ich ___ jetzt am Meer.", List.of("waere", "bin", "war", "ist"), 0, "For an unreal wish in the present, use waere."),
                question("An deiner Stelle ___ ich frueher schlafen.", List.of("wuerde", "werde", "wurde", "wird"), 0, "Advice with An deiner Stelle commonly uses wuerde."),
                question("Which sentence sounds more polite?", List.of("Ich will einen Kaffee.", "Ich haette gern einen Kaffee.", "Ich nehme Kaffee.", "Ich trinke Kaffee."), 1, "Ich haette gern is a more polite request than Ich will."),
                question("Wir ___ heute gern ausgehen, aber wir sind zu muede.", List.of("wuerden", "waren", "werden", "haben"), 0, "A polite or hypothetical idea uses wuerden."),
                question("What helper often builds Konjunktiv II in everyday German?", List.of("sein", "haben", "wuerde", "werden"), 2, "Many everyday Konjunktiv II forms are built with wuerde plus infinitive."),
                question("Er tut so, als ___ er alles.", List.of("wuesste", "weiss", "wusste", "gewusst"), 0, "As if situations often use Konjunktiv II: als wuesste er alles."),
                question("Which sentence expresses an unreal wish?", List.of("Wenn das Wetter doch besser waere!", "Das Wetter ist besser.", "Das Wetter war besser.", "Das Wetter wird besser."), 0, "The sentence with waere expresses an unreal wish.")
        );
    }

    private List<QuestionSeed> genitiveCaseQuestions() {
        return List.of(
                question("Das ist das Auto ___ Lehrers.", List.of("des", "dem", "den", "der"), 0, "To show possession with a masculine noun, use the genitive form des Lehrers."),
                question("Wegen ___ Regens bleiben wir zu Hause.", List.of("des", "den", "dem", "der"), 0, "Wegen commonly takes the genitive: wegen des Regens."),
                question("Die Farbe ___ Hauses ist weiss.", List.of("des", "dem", "den", "der"), 0, "To show possession with a neuter noun, use des Hauses."),
                question("Which article is genitive feminine?", List.of("die", "der", "dem", "den"), 1, "The genitive feminine article is der."),
                question("Trotz ___ Problems machen wir weiter.", List.of("des", "dem", "den", "der"), 0, "Trotz commonly takes the genitive: trotz des Problems."),
                question("Der Hund ___ Nachbarin ist laut.", List.of("der", "die", "dem", "den"), 0, "To show possession with a feminine noun, use der Nachbarin."),
                question("What does the genitive case often express?", List.of("Possession or belonging", "Only time", "Only movement", "A direct object"), 0, "The genitive often expresses possession or belonging."),
                question("Which preposition often takes the genitive?", List.of("mit", "fuer", "wegen", "ohne"), 2, "Wegen is a common genitive preposition."),
                question("Das Ende ___ Films war traurig.", List.of("des", "dem", "den", "der"), 0, "Film is masculine here, so the genitive is des Films."),
                question("Which is correct?", List.of("Die Wohnung meines Bruders ist klein.", "Die Wohnung mein Bruder ist klein.", "Die Wohnung meinem Bruder ist klein.", "Die Wohnung meinen Bruder ist klein."), 0, "The possessive genitive form is meines Bruders.")
        );
    }

    private List<QuestionSeed> adjectiveEndingQuestions() {
        return List.of(
                question("Der ___ Hund schlaeft.", List.of("kleine", "kleiner", "kleinen", "kleinem"), 0, "After the definite article der in the nominative masculine, the adjective ending is -e."),
                question("Ich sehe einen ___ Hund.", List.of("kleine", "kleiner", "kleinen", "kleinem"), 2, "After einen in the accusative masculine, the adjective ending is -en."),
                question("Das ___ Wasser ist kalt.", List.of("kalte", "kalter", "kalten", "kaltes"), 0, "After das in the nominative neuter, the adjective takes -e: das kalte Wasser."),
                question("Wir wohnen in einem ___ Haus.", List.of("kleine", "kleiner", "kleinen", "kleines"), 2, "After einem in the dative neuter, the adjective ending is -en."),
                question("___ Brot schmeckt gut.", List.of("Frische", "Frischer", "Frisches", "Frischen"), 2, "Without an article, a neuter nominative noun takes frisches."),
                question("Die ___ Tasche ist teuer.", List.of("rot", "rote", "roten", "roter"), 1, "After die in the nominative feminine, the adjective ending is -e."),
                question("Ich spreche mit meiner ___ Freundin.", List.of("gute", "guten", "guter", "gutem"), 1, "After meiner in the dative feminine, the adjective takes -en."),
                question("Which ending often appears after a definite article in the plural?", List.of("-e", "-en", "-er", "-es"), 1, "In many plural forms after definite articles, the adjective ending is -en."),
                question("Ich trinke ___ Kaffee.", List.of("kalte", "kalter", "kalten", "kaltes"), 2, "Without an article, a masculine accusative noun takes the ending -en: kalten Kaffee."),
                question("Which is correct?", List.of("die neuen Schuhe", "die neue Schuhe", "die neuer Schuhe", "die neues Schuhe"), 0, "With plural die, the adjective takes -en: die neuen Schuhe.")
        );
    }

    private List<QuestionSeed> plusquamperfektQuestions() {
        return List.of(
                question("Nachdem ich gegessen ___, ging ich spazieren.", List.of("hatte", "habe", "war", "bin"), 0, "An earlier past action with essen uses hatte plus the participle."),
                question("Wir ___ schon angekommen, bevor der Film begann.", List.of("waren", "sind", "haben", "hatten"), 0, "A movement verb often uses sein in the Plusquamperfekt: waren angekommen."),
                question("Er ___ eingeschlafen, bevor der Bus kam.", List.of("war", "ist", "hat", "hatte"), 0, "Einschlafen uses sein in the earlier past: war eingeschlafen."),
                question("What do you need to build the Plusquamperfekt?", List.of("Present tense plus infinitive", "Simple past of haben or sein plus past participle", "Only a modal verb", "Future tense plus participle"), 1, "The Plusquamperfekt uses the simple past of haben or sein with a past participle."),
                question("Sie ___ die Hausaufgaben schon gemacht, bevor sie fernsah.", List.of("hatte", "hat", "war", "ist"), 0, "Machen takes haben, so use hatte gemacht."),
                question("Ich ___ nach Hause gegangen, nachdem ich die Arbeit beendet hatte.", List.of("war", "bin", "habe", "hatte"), 0, "Gehen takes sein, so the correct form is war gegangen."),
                question("Which action happened first?", List.of("The action in Plusquamperfekt", "The action in Praesens", "The last noun", "The time phrase only"), 0, "The Plusquamperfekt marks the action that happened earlier in the past."),
                question("Maria ___ den Zug verpasst, bevor sie am Bahnhof ankam.", List.of("hatte", "hat", "war", "ist"), 0, "Verpassen takes haben, so use hatte verpasst."),
                question("We had never seen that.", List.of("Wir hatten das nie gesehen.", "Wir haben das nie gesehen.", "Wir waren das nie gesehen.", "Wir hatten das nie sehen."), 0, "The correct earlier past form is hatten gesehen."),
                question("Which helping verb often goes with movement verbs in the Plusquamperfekt?", List.of("werden", "sein", "koennen", "sollen"), 1, "Many movement verbs use sein in compound past forms.")
        );
    }

    private List<QuestionSeed> futurOneQuestions() {
        return List.of(
                question("Morgen ___ ich zu Hause bleiben.", List.of("werde", "wirst", "werden", "wird"), 0, "With ich, Futur I uses werde plus infinitive."),
                question("Wir ___ dich spaeter anrufen.", List.of("werde", "wirst", "werden", "wird"), 2, "With wir, the helping verb is werden."),
                question("Es ___ morgen regnen.", List.of("werde", "wirst", "werden", "wird"), 3, "With es, the correct form is wird."),
                question("What do you need for Futur I?", List.of("Werden plus infinitive", "Haben plus participle", "Only the present tense", "Sein plus adjective"), 0, "Futur I is built with werden plus an infinitive."),
                question("Sie ___ in zwei Jahren in Muenchen wohnen.", List.of("werde", "wirst", "werden", "wird"), 3, "With sie singular, Futur I uses wird."),
                question("Du ___ es bald verstehen.", List.of("werde", "wirst", "werden", "wird"), 1, "With du, the form is wirst."),
                question("Which sentence can express a guess about the present?", List.of("Er wird jetzt zu Hause sein.", "Er ist gestern zu Hause.", "Er war zu Hause.", "Er bleibt zu Hause."), 0, "Futur I can also express a probable assumption about the present."),
                question("Where does the main infinitive usually go in Futur I?", List.of("At the beginning", "In second position", "At the end", "Before the subject"), 2, "The main infinitive usually stays at the end of the clause."),
                question("Naechsten Monat ___ wir einen neuen Kurs beginnen.", List.of("werde", "wirst", "werden", "wird"), 2, "With wir, the correct future form is werden."),
                question("Which is correct?", List.of("Ich werde morgen arbeiten.", "Ich morgen werde arbeiten.", "Ich werde arbeiten morgen gehen.", "Ich arbeiten werde morgen."), 0, "The standard Futur I order is Ich werde morgen arbeiten.")
        );
    }

    private List<QuestionSeed> verbPrepositionQuestions() {
        return List.of(
                question("Ich warte ___ den Bus.", List.of("auf", "an", "mit", "zu"), 0, "Warten is commonly used with auf: warten auf."),
                question("Sie interessiert sich ___ moderne Kunst.", List.of("an", "mit", "fuer", "auf"), 2, "Sich interessieren is used with fuer."),
                question("Denkst du oft ___ deine Kindheit?", List.of("ueber", "an", "mit", "fuer"), 1, "Denken is often used with an in this meaning: an deine Kindheit denken."),
                question("Wir freuen uns ___ die Ferien.", List.of("fuer", "auf", "mit", "ueber"), 1, "Looking forward to something uses sich freuen auf."),
                question("Er spricht oft ___ seinem Chef.", List.of("auf", "mit", "fuer", "ohne"), 1, "Sprechen with a person often goes with mit."),
                question("Viele Menschen glauben ___ diese Idee.", List.of("in", "an", "mit", "ueber"), 1, "Glauben an is the common combination here."),
                question("Sie faengt morgen ___ dem neuen Projekt an.", List.of("an", "auf", "mit", "zu"), 2, "Anfangen is often combined with mit when starting an activity."),
                question("Er hat Angst ___ grossen Hunden.", List.of("mit", "zu", "vor", "fuer"), 2, "Angst haben is commonly used with vor."),
                question("Wir nehmen ___ dem Wettbewerb teil.", List.of("an", "auf", "mit", "fuer"), 0, "Teilnehmen is used with an."),
                question("Which sentence is correct?", List.of("Ich interessiere mich fuer Musik.", "Ich interessiere mich auf Musik.", "Ich interessiere Musik fuer.", "Ich interessiere mich Musik."), 0, "The fixed combination is sich interessieren fuer.")
        );
    }

    private List<QuestionSeed> infinitiveClauseQuestions() {
        return List.of(
                question("Ich lerne viel, ___ die Pruefung zu bestehen.", List.of("um", "ohne", "statt", "trotz"), 0, "Um ... zu expresses purpose: learning in order to pass the exam."),
                question("Er ging, ___ sich zu verabschieden.", List.of("um", "ohne", "statt", "bei"), 1, "Ohne ... zu expresses doing something without another action."),
                question("Sie faehrt mit dem Bus, ___ zu laufen.", List.of("um", "ohne", "statt", "wegen"), 2, "Statt ... zu expresses an alternative."),
                question("Which construction expresses purpose?", List.of("um ... zu", "ohne ... zu", "statt ... zu", "seit ... zu"), 0, "Um ... zu is used to express purpose."),
                question("Which is correct?", List.of("Ich rufe an, um einen Termin zu machen.", "Ich rufe an, ohne einen Termin zu machen.", "Ich rufe an, statt einen Termin zu machen.", "Ich rufe an, um einen Termin machen."), 0, "A purpose clause needs um ... zu plus the infinitive."),
                question("Which is correct?", List.of("Er ging, ohne ein Wort zu sagen.", "Er ging, ohne ein Wort sagen.", "Er ging, um ein Wort zu sagen ohne.", "Er ging, statt ein Wort zu sagen ohne."), 0, "Ohne ... zu plus infinitive is the correct structure."),
                question("Wir bestellen Essen, statt selbst ___ .", List.of("kochen", "zu kochen", "gekocht", "kochen zu"), 1, "After statt, use zu plus infinitive: statt selbst zu kochen."),
                question("Where does zu go in a separable infinitive like anrufen?", List.of("Before the whole verb: zuanrufen", "Between prefix and verb: anzurufen", "After the verb only", "It disappears"), 1, "With separable verbs, zu is inserted between the prefix and the stem: anzurufen."),
                question("Sie sparte Geld, um spaeter ein Haus ___ .", List.of("kaufen", "zu kaufen", "gekauft", "kauft"), 1, "Um ... zu needs the infinitive with zu: zu kaufen."),
                question("What do um ... zu clauses usually show?", List.of("Possession", "Purpose", "Comparison", "Past time"), 1, "Um ... zu clauses usually show purpose.")
        );
    }

    private List<QuestionSeed> wennClauseQuestions() {
        return List.of(
                question("Wenn ich Zeit habe, ___ ich vorbei.", List.of("komme", "kommen", "kommt", "kam"), 0, "In the main clause, the verb stays in second position: komme ich or ich komme."),
                question("Wenn es morgen regnet, ___ wir zu Hause.", List.of("bleiben", "bleibt", "bleibe", "blieb"), 0, "With wir, the main clause takes bleiben."),
                question("Where does the conjugated verb go in a wenn clause?", List.of("In first position", "In second position", "At the end", "Before the conjunction"), 2, "A wenn clause is subordinate, so the verb goes to the end."),
                question("Wenn ich mehr Geld haette, ___ ich ein neues Fahrrad kaufen.", List.of("wuerde", "werde", "bin", "habe"), 0, "An unreal condition is often followed by wuerde plus infinitive."),
                question("Wenn du mehr lernst, ___ du die Pruefung bestehen.", List.of("wirst", "wuerdest", "bist", "hast"), 0, "A real future result can use Futur I: wirst bestehen."),
                question("What happens when the wenn clause comes first?", List.of("The main clause verb still stays second", "The sentence must end", "The subject disappears", "The object moves to the front automatically"), 0, "Even after a fronted wenn clause, the main clause keeps the verb in second position."),
                question("Which conjunction introduces a condition?", List.of("weil", "dass", "wenn", "obwohl"), 2, "Wenn introduces a condition."),
                question("Wenn ich du ___, wuerde ich frueher anfangen.", List.of("waere", "bin", "war", "sei"), 0, "For an unreal condition, use the Konjunktiv II form waere."),
                question("Which is correct?", List.of("Wir gehen spazieren, wenn das Wetter gut ist.", "Wir gehen spazieren, wenn ist das Wetter gut.", "Wenn das Wetter gut ist, wir gehen spazieren.", "Wenn das Wetter gut, gehen wir spazieren."), 0, "The standard real condition is wenn das Wetter gut ist."),
                question("Wenn er anruft, ___ mir bitte Bescheid.", List.of("sag", "sagt", "sage", "sagen"), 0, "The imperative in the main clause is sag mir bitte Bescheid.")
        );
    }

    private VocabularyCategory ensureCategory(String name, String description, String iconName) {
        VocabularyCategory category = vocabularyCategoryRepository.findByName(name)
                .orElseGet(VocabularyCategory::new);
        category.setName(name);
        category.setDescription(description);
        category.setIconName(iconName);
        return vocabularyCategoryRepository.save(category);
    }

    private GrammarTopic ensureTopic(String title, String description, String level) {
        GrammarTopic topic = grammarTopicRepository.findByTitle(title)
                .orElseGet(GrammarTopic::new);
        topic.setTitle(title);
        topic.setDescription(description);
        topic.setLevel(level);
        return grammarTopicRepository.save(topic);
    }

    private void seedTopicQuestions(GrammarTopic topic, List<QuestionSeed> seeds) {
        for (QuestionSeed seed : seeds) {
            GrammarQuestion question = grammarQuestionRepository
                    .findByTopicIdAndQuestionOrderByIdAsc(topic.getId(), seed.question())
                    .stream()
                    .filter(existingQuestion -> existingQuestion.getExplanation().equals(seed.explanation()))
                    .findFirst()
                    .orElseGet(GrammarQuestion::new);
            question.setTopic(topic);
            question.setQuestion(seed.question());
            question.setOptions(seed.options());
            question.setCorrectAnswerIndex(seed.correctAnswerIndex());
            question.setExplanation(seed.explanation());
            question.setLevel(topic.getLevel());
            grammarQuestionRepository.save(question);
        }
    }

    private List<VocabularyCategorySeed> loadVocabularyCategorySeeds() {
        return VOCABULARY_CATEGORY_RESOURCES.stream()
                .flatMap(resourcePath -> readDelimitedResource(
                        resourcePath,
                        columns -> new VocabularyCategorySeed(columns[0], columns[1], columns[2])
                ).stream())
                .toList();
    }

    private List<VocabularyItemSeed> loadVocabularyItemSeeds() {
        return VOCABULARY_ITEM_RESOURCES.stream()
                .flatMap(resourcePath -> readDelimitedResource(
                        resourcePath,
                        columns -> new VocabularyItemSeed(columns[0], columns[1], columns[2], columns[3])
                ).stream())
                .toList();
    }

    private <T> List<T> readDelimitedResource(String resourcePath, SeedRowMapper<T> mapper) {
        ClassPathResource resource = new ClassPathResource(resourcePath);
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8)
        )) {
            return reader.lines()
                    .skip(1)
                    .map(String::trim)
                    .filter(line -> !line.isEmpty())
                    .filter(line -> !line.startsWith("#"))
                    .map(line -> line.split("\\|", -1))
                    .map(mapper::map)
                    .toList();
        } catch (IOException exception) {
            throw new IllegalStateException("Failed to load seed resource: " + resourcePath, exception);
        }
    }

    private String buildVocabularyExampleGerman(String german) {
        return "Heute uebe ich das Wort \"" + german + "\".";
    }

    private String buildVocabularyExampleEnglish(String english) {
        return "Today I practise the word \"" + english + "\".";
    }

    private String vocabularySeedKey(Long categoryId, String german) {
        return categoryId + "|" + german;
    }

    private static QuestionSeed question(
            String question,
            List<String> options,
            int correctAnswerIndex,
            String explanation
    ) {
        return new QuestionSeed(question, options, correctAnswerIndex, explanation);
    }

    private record VocabularyCategorySeed(
            String name,
            String description,
            String iconName
    ) {
    }

    private record VocabularyItemSeed(
            String categoryName,
            String level,
            String german,
            String english
    ) {
    }

    private record QuestionSeed(
            String question,
            List<String> options,
            int correctAnswerIndex,
            String explanation
    ) {
    }

    @FunctionalInterface
    private interface SeedRowMapper<T> {
        T map(String[] columns);
    }
}
