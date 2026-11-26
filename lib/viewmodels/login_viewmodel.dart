import 'package:frontend/data/network/requester.dart';
import 'package:frontend/data/repositores/cliente_repository.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';

class LoginViewmodel {
  final ClienteRepository _repository = ClienteRepository();

  AuthSession? session;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o seu e-mail';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a sua senha';
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final authSession = await _repository.login(email.trim(), password);
      session = authSession;
      await SessionStore.save(authSession);

      return null;
    } on RequestException catch (e) {
      if (e.statusCode == 401) {
        return 'E-mail ou senha incorretos.';
      }
      return e.message;
    } catch (_) {
      return 'Não foi possível entrar. Tente novamente.';
    }
  }
}
