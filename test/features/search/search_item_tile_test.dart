import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/storage/local_storage_provider.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/models/owner.dart';
import 'package:github_repo_app/features/search/view/widgets/search_item_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is NetworkImageLoadException) return;
    originalOnError?.call(details);
  };

  testWidgets('SearchItemTile renders title and toggles star icon on press', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final mockOwner = Owner(
      login: 'SeongyoungMoon',
      avatarUrl: 'https://example.com/avatar.png',
    );

    final mockRepo = GithubRepo(
      id: 202,
      name: 'github_repo_app',
      fullName: 'SeongyoungMoon/github_repo_app',
      subscribersCount: 46,
      owner: mockOwner,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SearchItemTile(repo: mockRepo),
          ),
        ),
      ),
    );

    // 1. Verify repository full name rendering
    expect(find.text('SeongyoungMoon/github_repo_app'), findsOneWidget);

    // 2. Verify initial state (unstarred icon)
    expect(find.byIcon(Icons.star_border), findsOneWidget);

    // 3. Tap the star button and trigger widget rebuild
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    // 4. Verify updated state (starred icon)
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}