import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> getPosts();
  Future<PostModel?> getPostById(String id);
  Future<PostModel> createPost(PostModel post);
}

class PostRepositoryImpl implements PostRepository {
  static const String _storageKey = 'cached_posts';
  final List<PostModel> _memoryPosts = [];

  PostRepositoryImpl() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? [];
      _memoryPosts.clear();
      for (var str in jsonList) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          _memoryPosts.add(PostModel.fromMap(map));
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          _memoryPosts.map((p) => jsonEncode(p.toMap())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }

  @override
  Future<List<PostModel>> getPosts() async {
    if (_memoryPosts.isEmpty) {
      await _loadFromStorage();
    }
    return List.unmodifiable(_memoryPosts);
  }

  @override
  Future<PostModel?> getPostById(String id) async {
    if (_memoryPosts.isEmpty) {
      await _loadFromStorage();
    }
    try {
      return _memoryPosts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    _memoryPosts.insert(0, post);
    await _saveToStorage();
    return post;
  }
}

