import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<String>>((ref) => BookmarksNotifier());

class BookmarksNotifier extends StateNotifier<List<String>> {
  BookmarksNotifier() : super([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('bookmarks') ?? [];
  }

  Future<void> addBookmark(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    final newBookmarks = List.of(state);
    newBookmarks.add(verse);
    state = newBookmarks;
    await prefs.setStringList('bookmarks', newBookmarks);
  }

  Future<void> removeBookmark(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    final newBookmarks = List.of(state);
    newBookmarks.remove(verse);
    state = newBookmarks;
    await prefs.setStringList('bookmarks', newBookmarks);
  }

  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', []);
    state = [];
  }
}