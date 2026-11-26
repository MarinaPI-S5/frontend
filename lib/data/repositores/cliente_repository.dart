import 'package:frontend/data/service/cliente_service.dart';
import 'package:frontend/data/service/login_service.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';
import 'package:frontend/models/cliente.dart';

class ClienteRepository {
  final ClienteService _clienteService = ClienteService();
  final LoginService _loginService = LoginService();

  Future<void> createCliente(Cliente cliente) async {
    await _clienteService.postCliente(cliente);
  }

  Future<AuthSession> login(String email, String password) async {
    final authResponse = await _loginService.login(email, password);

    await SessionStore.save(authResponse);

    return authResponse;
  }

  Future<void> restoreSession() async {
    await SessionStore.load();
  }

  Future<void> logout() async {
    await SessionStore.clear();
  }
}
