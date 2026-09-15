import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_repo_app/features/search/models/github_repo.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_repositories';
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  List<GithubRepo> getFavorites() {
    final List<String>? jsonList = _prefs.getStringList(_favoritesKey);
    if (jsonList == null) return [];

    return jsonList.map((item) {
      final Map<String, dynamic> jsonMap = jsonDecode(item) as Map<String, dynamic>;
      return GithubRepo.fromJson(jsonMap);
    }).toList();
  }

  Future<bool> saveFavorites(List<GithubRepo> favorites) async {
    final List<String> jsonList = favorites.map((repo) {
      return jsonEncode(repo.toJson());
    }).toList();

    return await _prefs.setStringList(_favoritesKey, jsonList);
  }
}