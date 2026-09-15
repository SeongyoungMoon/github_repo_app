import 'dart:convert';
import 'package:github_repo_app/features/search/models/github_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'favorite_repos';

  LocalStorageService(this._prefs);

  List<GithubRepo> getFavorites() {
    final String? jsonString = _prefs.getString(_favoritesKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => GithubRepo.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveFavorites(List<GithubRepo> repos) async {
    final String jsonString = jsonEncode(repos.map((repo) => repo.toJson()).toList());
    return await _prefs.setString(_favoritesKey, jsonString);
  }
}