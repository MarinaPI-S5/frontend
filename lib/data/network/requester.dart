import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:frontend/data/session/session_store.dart';

class Requester {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/api/v1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Requester() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionStore.current?.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<dynamic> post(
    String path,
    dynamic body, {
    Map<String, dynamic>? extraHeaders,
  }) async {
    try {
      final isFormData = body is FormData;
      final response = await _dio.post(
        path,
        data: isFormData ? body : jsonEncode(body),
        options: Options(
          contentType: isFormData ? 'multipart/form-data' : 'application/json',
          headers: extraHeaders,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw RequestException(
        _messageFor(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'O servidor demorou para responder.';

      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor.';

      case DioExceptionType.badResponse:
        return _messageFromBody(e.response) ??
            'O servidor recusou o pedido '
                '(código ${e.response?.statusCode}).';

      default:
        return 'Erro inesperado na requisição.';
    }
  }

  String? _messageFromBody(Response? response) {
    final data = response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    return null;
  }
}

class RequestException implements Exception {
  final String message;
  final int? statusCode;

  RequestException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
