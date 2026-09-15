import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_app/features/search/repositories/github_repository.dart';

void main() {
  group('GithubRepository Real API Integration Test', () {
    late GithubRepository githubRepository;

    setUp(() {
      githubRepository = GithubRepository();
    });

    test('Search API should correctly parse response into Model classes', () async {
      // 1. Fetch search repository data from GitHub REST API
      final results = await githubRepository.searchRepositories(query: 'github', page: 1);

      // 2. Validate response structure and data types
      expect(results, isNotEmpty);
      expect(results.first.id, isA<int>());
      expect(results.first.fullName, isA<String>());
      expect(results.first.owner.avatarUrl, isA<String>());

      // Log results for debugging verification
      print('\n[Search API Result]');
      print('First Repo: ${results.first.fullName}');
      print('Avatar URL: ${results.first.owner.avatarUrl}');
    });

    test('Repository Detail API should correctly parse subscribersCount', () async {
      // 1. Fetch repository detail data
      final detail = await githubRepository.fetchRepositoryDetail(
        owner: 'SeongyoungMoon',
        repoName: 'github_repo_app',
      );

      // 2. Validate detail attributes
      expect(detail.fullName, equals('SeongyoungMoon/github_repo_app'));
      expect(detail.subscribersCount, isNotNull);

      // Log results for debugging verification
      print('\n[Detail API Result]');
      print('Full Name: ${detail.fullName}');
      print('Subscribers Count: ${detail.subscribersCount}');
    });
  });
}