import 'package:frontend/data/network/requester.dart';
import 'package:frontend/models/cliente.dart';

class ClienteService {
  final Requester _requester = Requester();

  Future<void> postCliente(Cliente cliente) async {
    final body = {
      'name': cliente.name,
      'email': cliente.email,
      'cpf': cliente.cpf,
      'rg': cliente.rg,
      'password': cliente.password,
    };

    print('ENVIANDO JSON PARA O BACKEND: $body');

    await _requester.post('/client', body);
  }
}
