import 'package:frontend/data/network/requester.dart';
import 'package:frontend/models/auth_session.dart';

class LoginService {
  final Requester _requester = Requester();

  Future<AuthSession> login(String email, String password) async {
    final body = {'email': email, 'password': password, 'senha': password};

    final responseData = await _requester.post('/auth/login', body);

    return AuthSession.fromJson(responseData as Map<String, dynamic>);
  }
}
