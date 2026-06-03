import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';

class RestController extends ChangeNotifier {
  RestController({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  bool isLoading = false;
  String message = 'Ingrese un ID para consultar un post.';
  PostModel? currentPost;

  Future<void> fetchPost(String id) async {
    final trimmedId = id.trim();
    if (isLoading) return;

    if (trimmedId.isEmpty) {
      _setMessage('El ID no puede estar vacío.');
      debugPrint('[REST] action=GET id=EMPTY result=ERROR message=EMPTY_ID');
      return;
    }

    if (int.tryParse(trimmedId) == null) {
      _setMessage('El ID debe ser numérico.');
      debugPrint('[REST] action=GET id=$trimmedId result=ERROR message=INVALID_ID');
      return;
    }

    _setLoading(true, 'Consultando post...');
    currentPost = null;
    titleController.clear();
    bodyController.clear();
    notifyListeners();

    try {
      final response = await _apiService.getPost(trimmedId);
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          final post = PostModel.fromJson(decoded);
          if (post.title.isEmpty && post.body.isEmpty && post.id == 0) {
            _setMessage('Post no encontrado');
            debugPrint('[REST] action=GET id=$trimmedId result=NOT_FOUND');
          } else {
            currentPost = post;
            idController.text = post.id.toString();
            titleController.text = post.title;
            bodyController.text = post.body;
            _setMessage('Consulta exitosa');
            debugPrint('[REST] action=GET id=$trimmedId result=SUCCESS');
          }
        } else {
          _setMessage('Post no encontrado');
          debugPrint('[REST] action=GET id=$trimmedId result=NOT_FOUND');
        }
      } else if (response.statusCode == 404) {
        _setMessage('Post no encontrado');
        debugPrint('[REST] action=GET id=$trimmedId result=NOT_FOUND status=404');
      } else {
        _setMessage('Error de conexión');
        debugPrint('[REST] action=ERROR message=GET_STATUS_${response.statusCode}');
      }
    } on SocketException catch (error) {
      _setMessage('Error de conexión');
      debugPrint('[REST] action=ERROR message=${error.message}');
    } on TimeoutException catch (_) {
      _setMessage('Error de conexión');
      debugPrint('[REST] action=ERROR message=TIMEOUT');
    } catch (error) {
      _setMessage('Error de conexión');
      debugPrint('[REST] action=ERROR message=$error');
    } finally {
      _setLoading(false, message);
    }
  }

  Future<void> updatePost() async {
    if (isLoading) return;
    if (currentPost == null) {
      _setMessage('Debe consultar un post antes de actualizarlo.');
      debugPrint('[REST] action=PUT id=NONE result=ERROR message=NO_POST_LOADED');
      return;
    }

    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _setMessage('Title y body no pueden estar vacíos.');
      debugPrint('[REST] action=PUT id=${currentPost!.id} result=ERROR message=EMPTY_FIELDS');
      return;
    }

    _setLoading(true, 'Actualizando post...');

    try {
      final updatedPost = currentPost!.copyWith(title: title, body: body);
      final response = await _apiService.updatePost(updatedPost);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          currentPost = PostModel.fromJson(decoded);
        } else {
          currentPost = updatedPost;
        }

        idController.text = currentPost!.id.toString();
        titleController.text = currentPost!.title;
        bodyController.text = currentPost!.body;
        _setMessage('Actualización exitosa - Código 200 OK');
        debugPrint('[REST] action=PUT id=${currentPost!.id} status=200 result=SUCCESS');
      } else {
        _setMessage('Error al actualizar el post');
        debugPrint('[REST] action=PUT id=${currentPost!.id} status=${response.statusCode} result=ERROR');
      }
    } on SocketException catch (error) {
      _setMessage('Error de conexión');
      debugPrint('[REST] action=ERROR message=${error.message}');
    } on TimeoutException catch (_) {
      _setMessage('Error de conexión');
      debugPrint('[REST] action=ERROR message=TIMEOUT');
    } catch (error) {
      _setMessage('Error al actualizar el post');
      debugPrint('[REST] action=ERROR message=$error');
    } finally {
      _setLoading(false, message);
    }
  }

  void _setMessage(String newMessage) {
    message = newMessage;
    notifyListeners();
  }

  void _setLoading(bool value, String newMessage) {
    isLoading = value;
    message = newMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    idController.dispose();
    titleController.dispose();
    bodyController.dispose();
    _apiService.dispose();
    super.dispose();
  }
}

