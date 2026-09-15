import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/features/favorite/viewmodel/favorite_viewmodel.dart';
import 'package:github_repo_app/features/search/view/widgets/search_item_tile.dart';

class FavoriteView extends ConsumerWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Repositories'),
      ),
      body: favorites.isEmpty
          ? const Center(
        child: Text(
          'No favorite repositories yet.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final repo = favorites[index];
          return SearchItemTile(
            repo: repo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchItemTile(repo: repo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}