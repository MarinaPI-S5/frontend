import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/auth_session.dart';

class SessionStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_session';

  static final ValueNotifier<AuthSession?> notifier =
      ValueNotifier<AuthSession?>(null);

  static AuthSession? get current => notifier.value;

  static Future<void> save(AuthSession session) async {
    _setSession(session);
    final text = jsonEncode(session.toStorage());
    await _storage.write(key: _key, value: text);
  }

  static Future<void> load() async {
    final text = await _storage.read(key: _key);

    if (text == null) {
      _setSession(null);
      return;
    }

    try {
      final session = AuthSession.fromStorage(
        jsonDecode(text) as Map<String, dynamic>,
      );
      _setSession(session);
    } catch (_) {
      await clear();
    }
  }

  static Future<void> clear() async {
    _setSession(null);
    await _storage.delete(key: _key);
  }

  static void _setSession(AuthSession? session) {
    notifier.value = session;
  }
}
