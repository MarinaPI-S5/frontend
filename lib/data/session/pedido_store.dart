import 'package:flutter/foundation.dart';
import 'package:frontend/models/pedido.dart';

class PedidoStore {
  static final ValueNotifier<List<Pedido>> notifier =
      ValueNotifier<List<Pedido>>(<Pedido>[]);

  static List<Pedido> get current => notifier.value;

  static void adicionar(Pedido pedido) {
    notifier.value = [pedido, ...notifier.value];
  }

  static void limpar() {
    notifier.value = <Pedido>[];
  }
}
