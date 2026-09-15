import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/storage/local_storage_provider.dart';
import 'package:github_repo_app/features/favorite/viewmodel/favorite_viewmodel.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/models/owner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('FavoritesNotifier toggleFavorite adds and removes repo correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final mockOwner = Owner(
      login: 'SeongyoungMoon',
      avatarUrl: 'https://placehold.co/100x100.png',
    );

    final mockRepo = GithubRepo(
      id: 101,
      name: 'SeongyoungMoon',
      fullName: 'SeongyoungMoon/github_repo_app',
      subscribersCount: 46,
      owner: mockOwner,
    );

    // Initial state check
    expect(container.read(favoritesProvider), isEmpty);

    // 2. Toggle Add Test
    await container.read(favoritesProvider.notifier).toggleFavorite(mockRepo);
    expect(container.read(favoritesProvider).length, 1);
    expect(container.read(favoritesProvider).first.id, 101);

    // 3. Toggle Remove Test
    await container.read(favoritesProvider.notifier).toggleFavorite(mockRepo);
    expect(container.read(favoritesProvider), isEmpty);
  });
}