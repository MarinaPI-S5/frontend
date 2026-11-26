import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/pedido_store.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/widgets/pedidoCard.dart';
import 'package:http/http.dart' as http;

class Filapedidos extends StatefulWidget {
  const Filapedidos({super.key});

  @override
  State<Filapedidos> createState() => _FilapedidosState();
}

class _FilapedidosState extends State<Filapedidos> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _buscarPedidos();
  }

  Future<List<Pedido>> _buscarPedidos() async {
    final session = SessionStore.current;
    final token = session?.token.trim() ?? '';
    final userId = session?.user.id.trim() ?? '';
    final emailUsuario = session?.user.email.trim().toLowerCase() ?? '';

    final response = await http.get(
      Uri.parse('$_baseUrl/departure'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 400 || response.statusCode == 404) {
      return [];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao carregar agendamentos (${response.statusCode})');
    }

    if (response.body.trim().isEmpty) return [];

    final decoded = jsonDecode(response.body);
    final List<dynamic> listaBruta;

    if (decoded is List) {
      listaBruta = decoded;
    } else if (decoded is Map) {
      final candidato =
          decoded['data'] ??
          decoded['departures'] ??
          decoded['pedidos'] ??
          decoded['items'];
      listaBruta = candidato is List ? candidato : [];
    } else {
      listaBruta = [];
    }

    final todos = listaBruta
        .whereType()
        .map((item) => Pedido.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (userId.isNotEmpty || emailUsuario.isNotEmpty) {
      final doUsuario = todos.where((pedido) {
        final matchId = userId.isNotEmpty && pedido.clientId == userId;
        final matchEmail =
            emailUsuario.isNotEmpty &&
            pedido.responsavel.trim().toLowerCase() == emailUsuario;
        return matchId || matchEmail;
      }).toList();

      PedidoStore.definirPedidosUsuario(
        userId.isNotEmpty ? userId : emailUsuario,
        doUsuario,
      );
      return doUsuario;
    }

    return todos;
  }

  Future<void> _recarregar() async {
    setState(() {
      _pedidosFuture = _buscarPedidos();
    });
    await _pedidosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Fila de agendamentos'),
        actions: [
          IconButton(onPressed: _recarregar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Pedido>>(
          future: _pedidosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${snapshot.error}'.replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _recarregar,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final pedidos = snapshot.data ?? [];
            if (pedidos.isEmpty) {
              return RefreshIndicator(
                onRefresh: _recarregar,
                child: ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Nenhum agendamento encontrado.')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _recarregar,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedidoAtual = pedidos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Center(child: PedidoCard(pedido: pedidoAtual)),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
