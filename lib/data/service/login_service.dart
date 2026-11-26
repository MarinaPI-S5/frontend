import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/data/network/requester.dart';
import 'package:frontend/models/auth_session.dart';

class LoginService {
  final Requester _requester = Requester();

  Future<AuthSession> login(String email, String password) async {
    final body = {'email': email, 'password': password, 'senha': password};

    final responseData = await _requester.post('/auth/login', body);
    debugPrint('LOGIN RESPONSE -> $responseData');

    final session = AuthSession.fromJson(responseData as Map<String, dynamic>);
    final payload = _decodeJwtPayload(session.token);

    debugPrint(
      'AUTH SESSION -> id: ${session.user.id}, email: ${session.user.email}, '
      'role: ${session.user.role}, isAdmin: ${session.user.isAdmin}, jwtPayload: $payload',
    );

    return session;
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return <String, dynamic>{};
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
