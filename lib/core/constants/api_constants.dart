class ApiConstants {
  static const String baseUrl = 'https://api.github.com';
  static const String searchRepositories = '$baseUrl/search/repositories';
  static const int perPage = 20;

  static String repositoryDetail(String owner, String repoName) {
    return '$baseUrl/repos/$owner/$repoName';
  }
}