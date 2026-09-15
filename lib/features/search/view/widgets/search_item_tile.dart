import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/favorite/viewmodel/favorite_viewmodel.dart';

class SearchItemTile extends ConsumerWidget {
  final GithubRepo repo;
  final VoidCallback? onTap;

  const SearchItemTile({
    super.key,
    required this.repo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((item) => item.id == repo.id);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(repo.owner.avatarUrl),
      ),
      title: Text(
        repo.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: IconButton(
        icon: Icon(
          isFav ? Icons.star : Icons.star_border,
          color: isFav ? Colors.deepPurple : Colors.grey,
        ),
        highlightColor: Colors.transparent,
        onPressed: () {
          ref.read(favoritesProvider.notifier).toggleFavorite(repo);
        },
      ),
    );
  }
}