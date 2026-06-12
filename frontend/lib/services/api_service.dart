import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/grammar_question.dart';
import '../models/grammar_topic.dart';
import '../models/vocabulary_category.dart';
import '../models/vocabulary_word.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<VocabularyCategory>> getVocabularyCategories() async {
    final data = await _getList('/vocab/categories');
    return data.map(VocabularyCategory.fromJson).toList();
  }

  Future<VocabularyCategory> getVocabularyCategory(int id) async {
    final data = await _getMap('/vocab/categories/$id');
    return VocabularyCategory.fromJson(data);
  }

  Future<List<VocabularyWord>> getVocabulary({
    int? categoryId,
    String? level,
  }) async {
    final queryParameters = <String, String>{};
    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId.toString();
    }
    if (level != null && level.isNotEmpty) {
      queryParameters['level'] = level;
    }

    final data = await _getList(
      '/vocab',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return data.map(VocabularyWord.fromJson).toList();
  }

  Future<VocabularyWord> getVocabularyById(int id) async {
    final data = await _getMap('/vocab/$id');
    return VocabularyWord.fromJson(data);
  }

  Future<List<VocabularyWord>> getVocabularyByIds(Iterable<int> ids) async {
    final items = await Future.wait(ids.map(getVocabularyById));
    items.sort((a, b) => a.german.compareTo(b.german));
    return items;
  }

  Future<List<GrammarTopic>> getGrammarTopics({String? level}) async {
    final data = await _getList(
      '/grammar/topics',
      queryParameters: level == null || level.isEmpty ? null : {'level': level},
    );
    return data.map(GrammarTopic.fromJson).toList();
  }

  Future<GrammarTopic> getGrammarTopic(int id) async {
    final data = await _getMap('/grammar/topics/$id');
    return GrammarTopic.fromJson(data);
  }

  Future<List<GrammarQuestion>> getGrammarQuestions({
    int? topicId,
    String? level,
  }) async {
    final queryParameters = <String, String>{};
    if (topicId != null) {
      queryParameters['topicId'] = '$topicId';
    }
    if (level != null && level.isNotEmpty) {
      queryParameters['level'] = level;
    }

    final data = await _getList(
      '/grammar/questions',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return data.map(GrammarQuestion.fromJson).toList();
  }

  Future<GrammarQuestion> getGrammarQuestion(int id) async {
    final data = await _getMap('/grammar/questions/$id');
    return GrammarQuestion.fromJson(data);
  }

  Future<List<GrammarQuestion>> getGrammarQuestionsByIds(Iterable<int> ids) async {
    final items = await Future.wait(
      ids.map((id) async {
        try {
          return await getGrammarQuestion(id);
        } catch (_) {
          return null;
        }
      }),
    );
    return items.whereType<GrammarQuestion>().toList();
  }

  Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(_buildUri(path, queryParameters));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed with status ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(_buildUri(path, queryParameters));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed with status ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    return Uri.parse(
      '${AppConfig.apiBaseUrl}$path',
    ).replace(queryParameters: queryParameters);
  }
}
