import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/repositories/github_repository.dart';

final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  return GithubRepository();
});

class SearchState {
  final List<GithubRepo> repos;
  final bool isLoading;
  final bool isFetchingNextPage;
  final bool hasMore;
  final int currentPage;
  final String currentQuery;
  final String? errorMessage;

  const SearchState({
    this.repos = const [],
    this.isLoading = false,
    this.isFetchingNextPage = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.currentQuery = '',
    this.errorMessage,
  });

  SearchState copyWith({
    List<GithubRepo>? repos,
    bool? isLoading,
    bool? isFetchingNextPage,
    bool? hasMore,
    int? currentPage,
    String? currentQuery,
    String? errorMessage,
  }) {
    return SearchState(
      repos: repos ?? this.repos,
      isLoading: isLoading ?? this.isLoading,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      currentQuery: currentQuery ?? this.currentQuery,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  late final GithubRepository _repository;

  @override
  SearchState build() {
    _repository = ref.watch(githubRepositoryProvider);
    return const SearchState();
  }

  /// 첫 페이지 검색
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = SearchState(
      isLoading: true,
      currentQuery: query,
    );

    try {
      final results = await _repository.searchRepositories(query: query, page: 1);
      state = state.copyWith(
        repos: results,
        isLoading: false,
        hasMore: results.isNotEmpty,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred while searching repositories.',
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isFetchingNextPage || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isFetchingNextPage: true);

    try {
      final nextPage = state.currentPage + 1;
      final newResults = await _repository.searchRepositories(
        query: state.currentQuery,
        page: nextPage,
      );

      state = state.copyWith(
        repos: [...state.repos, ...newResults],
        isFetchingNextPage: false,
        hasMore: newResults.isNotEmpty,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isFetchingNextPage: false);
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});