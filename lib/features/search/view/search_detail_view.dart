import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/features/favorite/viewmodel/favorite_viewmodel.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/viewmodel/search_viewmodel.dart';

class SearchDetailView extends ConsumerStatefulWidget {
  final GithubRepo repo;

  const SearchDetailView({
    super.key,
    required this.repo,
  });

  @override
  ConsumerState<SearchDetailView> createState() => _SearchDetailViewState();
}

class _SearchDetailViewState extends ConsumerState<SearchDetailView> {
  GithubRepo? _detailRepo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final repository = ref.read(githubRepositoryProvider);
      final detail = await repository.fetchRepositoryDetail(
        owner: widget.repo.owner.login,
        repoName: widget.repo.name,
      );

      if (mounted) {
        setState(() {
          _detailRepo = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load details.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = _detailRepo ?? widget.repo;
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((item) => item.id == repo.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(repo.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.deepPurple : null,
            ),
            highlightColor: Colors.transparent,
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(repo);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(repo.owner.avatarUrl),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.remove_red_eye_outlined,
              'Subscribers (Watchers)',
              '${repo.subscribersCount ?? "N/A"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(value),
      ],
    );
  }
}