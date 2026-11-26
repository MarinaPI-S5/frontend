import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/pedido.dart';

class PedidoStore {
  static const _storage = FlutterSecureStorage();
  static const _prefixKey = 'pedidos_usuario_';

  static final ValueNotifier<List<Pedido>> notifier =
      ValueNotifier<List<Pedido>>(<Pedido>[]);

  static final Map<String, List<Pedido>> _pedidosPorUsuario =
      <String, List<Pedido>>{};

  static String _chaveStorage(String userId) => '$_prefixKey${userId.trim()}';

  static List<Pedido> get current => notifier.value;

  static Future<void> definirPedidosUsuario(
    String? userId,
    List<Pedido> pedidos,
  ) async {
    final listaCopia = List<Pedido>.from(pedidos);
    final chave = userId?.trim() ?? '';
    if (chave.isNotEmpty) {
      _pedidosPorUsuario[chave] = listaCopia;
      await _persistirNoStorage(chave, listaCopia);
    }
    notifier.value = listaCopia;
  }

  static Future<void> carregarDoCacheUsuario(String? userId) async {
    final chave = userId?.trim() ?? '';
    if (chave.isEmpty) {
      notifier.value = <Pedido>[];
      return;
    }

    if (_pedidosPorUsuario.containsKey(chave) &&
        _pedidosPorUsuario[chave]!.isNotEmpty) {
      notifier.value = List<Pedido>.from(_pedidosPorUsuario[chave]!);
      return;
    }

    try {
      final raw = await _storage.read(key: _chaveStorage(chave));
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final recuperados = decoded
              .whereType()
              .map((item) => Pedido.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _pedidosPorUsuario[chave] = recuperados;
          notifier.value = List<Pedido>.from(recuperados);
          return;
        }
      }
    } catch (_) {}

    if (_pedidosPorUsuario.containsKey(chave)) {
      notifier.value = List<Pedido>.from(_pedidosPorUsuario[chave]!);
    } else {
      notifier.value = <Pedido>[];
    }
  }

  static Future<void> adicionar(Pedido pedido, {String? userId}) async {
    final chave = userId?.trim() ?? '';
    final baseAtual =
        (chave.isNotEmpty && _pedidosPorUsuario.containsKey(chave))
        ? _pedidosPorUsuario[chave]!
        : notifier.value;

    final semDuplicado = pedido.id != null && pedido.id!.trim().isNotEmpty
        ? baseAtual.where((p) => p.id != pedido.id).toList()
        : List<Pedido>.from(baseAtual);

    final atualizada = [pedido, ...semDuplicado];
    notifier.value = atualizada;

    if (chave.isNotEmpty) {
      _pedidosPorUsuario[chave] = List<Pedido>.from(atualizada);
      await _persistirNoStorage(chave, atualizada);
    }
  }

  static Future<void> _persistirNoStorage(
    String chave,
    List<Pedido> pedidos,
  ) async {
    try {
      final listaJson = pedidos.map((p) => p.toJson()).toList();
      await _storage.write(
        key: _chaveStorage(chave),
        value: jsonEncode(listaJson),
      );
    } catch (_) {}
  }

  static void limpar() {
    notifier.value = <Pedido>[];
  }

  static Future<void> limparTudo() async {
    for (final chave in _pedidosPorUsuario.keys) {
      try {
        await _storage.delete(key: _chaveStorage(chave));
      } catch (_) {}
    }
    _pedidosPorUsuario.clear();
    notifier.value = <Pedido>[];
  }
}
