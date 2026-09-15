import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_app/core/event/ui_event.dart';
import 'package:github_repo_app/features/search/view/search_detail_view.dart';
import 'package:github_repo_app/features/search/view/widgets/search_item_tile.dart';
import 'package:github_repo_app/features/search/viewmodel/search_viewmodel.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<UiEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventSubscription = ref
          .read(searchProvider.notifier)
          .eventStream
          .listen((event) {
        if (!mounted) return;

        switch (event) {
          case ShowSnackBarEvent(:final message):
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.fixed,
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final searchState = ref.read(searchProvider);
      if (!searchState.isFetchingNextPage && !searchState.isLoading) {
        ref.read(searchProvider.notifier).fetchNextPage();
      }
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
              onChanged: (text) {
                if (text.trim().isEmpty) {
                  setState(() {});
                }
              },
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
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search GitHub Repositories',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

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