import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/event/ui_event.dart';
import 'package:github_repo_app/core/network/api_exception.dart';
import 'package:github_repo_app/core/utils/throttler.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/repositories/search_repository.dart';
import 'package:github_repo_app/features/search/repositories/search_api_error_handler.dart';

final githubRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
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
  late final SearchRepository _repository;
  final _scrollThrottler = Throttler(duration: const Duration(milliseconds: 300));
  final _eventController = StreamController<UiEvent>.broadcast();

  Stream<UiEvent> get eventStream => _eventController.stream;

  @override
  SearchState build() {
    _repository = ref.watch(githubRepositoryProvider);

    ref.onDispose(() {
      _eventController.close();
    });

    return const SearchState();
  }

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
    } on ApiException catch (e) {
      final errorMessage = handleSearchApiError(e);

      state = state.copyWith(
        isLoading: false,
        isFetchingNextPage: false,
      );

      _eventController.sink.add(ShowSnackBarEvent(errorMessage));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingNextPage: false,
      );

      _eventController.sink.add(ShowSnackBarEvent('Unexpected error occurred.'));
    }
  }

  Future<void> fetchNextPage() async {
    _scrollThrottler.run(() async {
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
      } on ApiException catch (e) {
        final errorMessage = handleSearchApiError(e);
        state = state.copyWith(isFetchingNextPage: false,);
        _eventController.sink.add(ShowSnackBarEvent(errorMessage));
      } catch (e) {
        state = state.copyWith(isFetchingNextPage: false);
        _eventController.sink.add(ShowSnackBarEvent('Failed to load next page.'));
      }
    });
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});