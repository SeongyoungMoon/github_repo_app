import 'package:flutter/material.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';

class SearchItemTile extends StatefulWidget {
  final GithubRepo repo;
  final VoidCallback? onTap;

  const SearchItemTile({
    super.key,
    required this.repo,
    this.onTap,
  });

  @override
  State<SearchItemTile> createState() => _SearchItemTileState();
}

class _SearchItemTileState extends State<SearchItemTile> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(widget.repo.owner.avatarUrl),
      ),
      title: Text(
        widget.repo.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: IconButton(
        icon: Icon(
          isFav ? Icons.star : Icons.star_border,
          color: isFav ? Colors.deepPurple : Colors.grey,
        ),
        highlightColor: Colors.transparent,
        onPressed: () {
          /// TODO: connect to local storage
          setState(() {
            isFav = !isFav;
          });
        },
      ),
    );
  }
}