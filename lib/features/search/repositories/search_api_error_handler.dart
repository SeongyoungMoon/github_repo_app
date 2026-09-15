import 'package:github_repo_app/core/network/api_exception.dart';

String handleSearchApiError(ApiException exception) {
  final statusCode = exception.statusCode;

  if (statusCode == null) {
    return 'An unknown error occurred.';
  }

  switch (statusCode) {
    case 301:
      return 'The requested resource has been moved permanently.';
    case 304:
      return 'Not modified.';
    case 403:
      return 'Access forbidden or API rate limit exceeded.';
    case 404:
      return 'Resource not found.';
    case 422:
      return 'Validation failed or request limit reached.';
    case 503:
      return 'Service unavailable. Please try again later.';
    default:
      if (statusCode >= 500) {
        return 'Server error ($statusCode). Please try again.';
      }
      return 'An unexpected error occurred ($statusCode).';
  }
}