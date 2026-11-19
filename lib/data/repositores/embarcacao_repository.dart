import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/network/embarcacao_request.dart';
import 'package:frontend/models/documento_embarcacao.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EmbarcacaoRepository {
  final String baseUrl;
  final http.Client _client;

  EmbarcacaoRepository({
    this.baseUrl = 'http://localhost:3000/api/v1/',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _buildUri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$normalizedBase/$normalizedPath');
  }

  Future<DocumentoEmbarcacao?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final extension = (file.extension ?? '').toLowerCase();
    const allowed = {'pdf', 'jpg', 'jpeg', 'png'};

    if (extension.isNotEmpty && !allowed.contains(extension)) {
      throw Exception('Formato não suportado. Use PDF, JPG ou PNG.');
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Não foi possível ler os dados do arquivo selecionado.');
    }

    return DocumentoEmbarcacao(
      name: file.name,
      path: kIsWeb ? null : file.path,
      bytes: bytes,
      sizeInBytes: file.size > 0 ? file.size : bytes.length,
    );
  }

  Future<void> criarEmbarcacao(EmbarcacaoRequest requestData) async {
    final uri = _buildUri('/boat');
    final request = http.MultipartRequest('POST', uri);

    request.fields['id'] = requestData.clienteId;
    request.fields['name'] = requestData.name;

    if (requestData.boatdoc != null) {
      final multipartFile = await _toMultipartFile(
        fieldName: 'boatdoc',
        documento: requestData.boatdoc!,
      );
      if (multipartFile != null) {
        request.files.add(multipartFile);
      }
    }

    if (requestData.insurance != null) {
      final multipartFile = await _toMultipartFile(
        fieldName: 'insurance',
        documento: requestData.insurance!,
      );
      if (multipartFile != null) {
        request.files.add(multipartFile);
      }
    }

    // Se o backend usar token Bearer na sessão, adicione aqui:
    // final token = SessionStore.notifier.value?.token;
    // if (token != null && token.isNotEmpty) {
    //   request.headers['Authorization'] = 'Bearer $token';
    // }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro ao cadastrar embarcação (${response.statusCode}).';
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          } else {
            message = _extractErrorText(response.body);
          }
        } catch (_) {
          message = _extractErrorText(response.body);
        }
      }
      throw Exception(message);
    }
  }

  String _extractErrorText(String body) {
    final preMatch = RegExp(
      r'<pre>([\s\S]*?)<\/pre>',
      caseSensitive: false,
    ).firstMatch(body);
    if (preMatch != null && preMatch.group(1) != null) {
      return preMatch
          .group(1)!
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .trim();
    }
    return body.trim();
  }

  MediaType? _detectMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    return null;
  }

  Future<http.MultipartFile?> _toMultipartFile({
    required String fieldName,
    required DocumentoEmbarcacao documento,
  }) async {
    final mediaType = _detectMediaType(documento.name);

    if (documento.bytes != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        documento.bytes!,
        filename: documento.name,
        contentType: mediaType,
      );
    }

    if (!kIsWeb && documento.path != null && documento.path!.isNotEmpty) {
      return http.MultipartFile.fromPath(
        fieldName,
        documento.path!,
        filename: documento.name,
        contentType: mediaType,
      );
    }

    return null;
  }
}
