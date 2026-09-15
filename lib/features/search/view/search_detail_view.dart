import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/network/api_exception.dart';
import 'package:github_repo_app/features/favorite/viewmodel/favorite_viewmodel.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:github_repo_app/features/search/repositories/search_api_error_handler.dart';
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
    } on ApiException catch (e) {
      if (!mounted) return;

      final errorMessage = handleSearchApiError(e);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load details.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
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
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Image.network(
                      repo.owner.avatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.grey);
                      },
                    ),
                  ),
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