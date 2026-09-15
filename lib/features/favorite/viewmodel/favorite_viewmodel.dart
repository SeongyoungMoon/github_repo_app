import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/storage/local_storage_provider.dart';
import 'package:github_repo_app/core/storage/local_storage_service.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';

class FavoritesNotifier extends Notifier<List<GithubRepo>> {
  late final LocalStorageService _storageService;

  @override
  List<GithubRepo> build() {
    _storageService = ref.watch(localStorageServiceProvider);
    return _storageService.getFavorites();
  }

  Future<void> toggleFavorite(GithubRepo repo) async {
    final isExist = state.any((item) => item.id == repo.id);
    List<GithubRepo> updatedList;

    if (isExist) {
      updatedList = state.where((item) => item.id != repo.id).toList();
    } else {
      updatedList = [...state, repo];
    }

    state = updatedList;
    await _storageService.saveFavorites(updatedList);
  }

  bool isFavorite(int repoId) {
    return state.any((item) => item.id == repoId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<GithubRepo>>(() {
  return FavoritesNotifier();
});