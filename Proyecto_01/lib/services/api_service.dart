import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<http.Response> getPost(String id) {
    final uri = Uri.parse('$_baseUrl/posts/$id');
    return _client.get(uri);
  }

  Future<http.Response> updatePost(PostModel post) {
    final uri = Uri.parse('$_baseUrl/posts/${post.id}');
    return _client.put(
      uri,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(post.toJson()),
    );
  }

  void dispose() {
    _client.close();
  }
}

