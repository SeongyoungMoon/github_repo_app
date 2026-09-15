import 'dart:convert';
import 'package:github_repo_app/core/constants/api_constants.dart';
import 'package:github_repo_app/core/network/api_exception.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:http/http.dart' as http;


class GithubRepository {
  final http.Client _client;

  GithubRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<GithubRepo>> searchRepositories({
    required String query,
    int page = 1,
  }) async {
    if (query.trim().isEmpty) return [];

    final Uri url = Uri.parse(
      '${ApiConstants.searchRepositories}?q=${Uri.encodeComponent(query)}&page=$page&per_page=${ApiConstants.perPage}',
    );

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to search repositories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }

  Future<GithubRepo> fetchRepositoryDetail({
    required String owner,
    required String repoName,
  }) async {
    final Uri url = Uri.parse(ApiConstants.repositoryDetail(owner, repoName));

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GithubRepo.fromJson(data);
      } else {
        throw ApiException(
          'Failed to fetch repository details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection error: ${e.toString()}');
    }
  }
}