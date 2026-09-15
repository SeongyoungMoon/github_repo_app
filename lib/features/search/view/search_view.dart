import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/features/search/view/search_detail_view.dart';
import 'package:github_repo_app/features/search/view/widgets/search_item_tile.dart'
    show SearchItemTile;
import 'package:github_repo_app/features/search/viewmodel/search_viewmodel.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(searchProvider.notifier).fetchNextPage();
    }
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();
    ref.read(searchProvider.notifier).search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repository Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search repositories...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          Expanded(
            child: _buildBody(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    if (state.repos.isEmpty) {
      return const Center(
        child: Text('No repositories found.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.repos.length + (state.isFetchingNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.repos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final repo = state.repos[index];
        return SearchItemTile(
          repo: repo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchDetailView(repo: repo),
              ),
            );
          },
        );
      },
    );
  }
}