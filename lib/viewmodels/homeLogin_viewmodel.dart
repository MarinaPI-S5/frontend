import 'package:flutter/foundation.dart';
import 'package:frontend/data/repositores/cliente_repository.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';

class HomeViewModel {
  final ClienteRepository _repository = ClienteRepository();

  ValueListenable<AuthSession?> get sessionListenable => SessionStore.notifier;

  String? greeting(AuthSession? session) {
    if (session == null) return null;

    final emailName = session.user.email.split('@').first;

    final firstName = emailName[0].toUpperCase() + emailName.substring(1);

    return 'Olá, $firstName';
  }
}
