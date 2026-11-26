import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/pages/cadastroCliente_page.dart';
import 'package:frontend/views/pages/cadastroEmbarcacao_page.dart';
import 'package:frontend/views/pages/filaAvaliacao_page.dart';
import 'package:frontend/views/widgets/adminBottomNav.dart';
import 'package:http/http.dart' as http;

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  bool _isLoadingPedidos = false;
  String? _erroPedidos;
  List<_PedidoAdminItem> _pedidos = [];
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarPedidosClientes();
  }

  bool _pareceEmail(String valor) {
    final v = valor.trim();
    return v.contains('@') && v.contains('.');
  }

  String _extrairNomeProprietario(Map<String, dynamic> rawJson, Pedido pedido) {
    final clientMap = rawJson['client'] is Map
        ? Map<String, dynamic>.from(rawJson['client'] as Map)
        : (rawJson['cliente'] is Map
              ? Map<String, dynamic>.from(rawJson['cliente'] as Map)
              : <String, dynamic>{});

    final ownerMap = rawJson['owner'] is Map
        ? Map<String, dynamic>.from(rawJson['owner'] as Map)
        : (rawJson['proprietario'] is Map
              ? Map<String, dynamic>.from(rawJson['proprietario'] as Map)
              : <String, dynamic>{});

    final userMap = rawJson['user'] is Map
        ? Map<String, dynamic>.from(rawJson['user'] as Map)
        : <String, dynamic>{};

    final candidatos = [
      clientMap['name'],
      clientMap['nome'],
      ownerMap['name'],
      ownerMap['nome'],
      userMap['name'],
      userMap['nome'],
      rawJson['clienteNome'],
      rawJson['nomeCliente'],
      rawJson['nomeProprietario'],
      rawJson['responsavel'],
      pedido.responsavel,
    ];

    // 1ª passada: prioriza qualquer nome válido que não seja e-mail
    for (final c in candidatos) {
      if (c != null) {
        final texto = c.toString().trim();
        if (texto.isNotEmpty && !_pareceEmail(texto)) {
          return texto;
        }
      }
    }

    // 2ª passada: fallback caso exista apenas e-mail
    for (final c in candidatos) {
      if (c != null) {
        final texto = c.toString().trim();
        if (texto.isNotEmpty) {
          return texto;
        }
      }
    }

    return 'Proprietário';
  }

  String _extrairNomeEmbarcacao(Map<String, dynamic> rawJson, Pedido pedido) {
    final boatMap = rawJson['boat'] is Map
        ? Map<String, dynamic>.from(rawJson['boat'] as Map)
        : (rawJson['embarcacao'] is Map
              ? Map<String, dynamic>.from(rawJson['embarcacao'] as Map)
              : <String, dynamic>{});

    final candidatos = [
      boatMap['name'],
      boatMap['nome'],
      rawJson['boatName'],
      rawJson['nomeEmbarcacao'],
      pedido.embarcacao,
    ];

    for (final c in candidatos) {
      if (c != null && c.toString().trim().isNotEmpty) {
        return c.toString().trim();
      }
    }

    return 'Embarcação';
  }

  Future<void> _carregarPedidosClientes() async {
    final token = SessionStore.current?.token.trim() ?? '';

    if (mounted) {
      setState(() {
        _isLoadingPedidos = true;
        _erroPedidos = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/departure'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 400 || response.statusCode == 404) {
        if (mounted) {
          setState(() {
            _pedidos = [];
          });
        }
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Erro ao carregar pedidos (${response.statusCode})');
      }

      final List<dynamic> listaBruta;
      if (response.body.trim().isEmpty) {
        listaBruta = [];
      } else {
        final decoded = jsonDecode(response.body);
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
      }

      final pedidosCarregados = listaBruta.whereType().map((item) {
        final rawMap = Map<String, dynamic>.from(item);
        final pedido = Pedido.fromJson(rawMap);
        final nomeProprietario = _extrairNomeProprietario(rawMap, pedido);
        final nomeEmbarcacao = _extrairNomeEmbarcacao(rawMap, pedido);
        return _PedidoAdminItem(
          pedido: pedido,
          nomeCliente: nomeProprietario,
          nomeEmbarcacao: nomeEmbarcacao,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _pedidos = pedidosCarregados;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erroPedidos = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPedidos = false;
        });
      }
    }
  }

  Future<void> _abrirFilaAvaliacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilaavaliacaoPage()),
    );
    if (mounted) {
      _carregarPedidosClientes();
    }
  }

  Future<void> _onNavSelected(int index) async {
    if (index == 0) {
      setState(() => _selectedNavIndex = 0);
      await _carregarPedidosClientes();
      return;
    }

    if (index == 1) {
      setState(() => _selectedNavIndex = 1);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CadastroclientePage()),
      );
      if (mounted) {
        setState(() => _selectedNavIndex = 0);
        _carregarPedidosClientes();
      }
    } else if (index == 2) {
      setState(() => _selectedNavIndex = 2);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CadastroembarcacaoPage()),
      );
      if (mounted) {
        setState(() => _selectedNavIndex = 0);
        _carregarPedidosClientes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrador'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: _onNavSelected,
      ),
      body: RefreshIndicator(
        onRefresh: _carregarPedidosClientes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'O que deseja fazer?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context: context,
                              icon: Icons.receipt_long,
                              color: Colors.green,
                              title: 'Avaliar\nPedidos',
                              onTap: _abrirFilaAvaliacao,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              context: context,
                              icon: Icons.arrow_back,
                              color: Colors.blue,
                              title: 'Lista de\nRetorno',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CadastroembarcacaoPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pedidos / Saídas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                onPressed: _isLoadingPedidos
                                    ? null
                                    : _carregarPedidosClientes,
                                icon: const Icon(Icons.refresh, size: 20),
                                tooltip: 'Atualizar pedidos',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingPedidos && _pedidos.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_erroPedidos != null && _pedidos.isEmpty)
                            Text(
                              _erroPedidos!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            )
                          else if (_pedidos.isEmpty)
                            const Text(
                              'Nenhum pedido registrado.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pedidos.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 12),
                              itemBuilder: (context, index) {
                                final item = _pedidos[index];
                                final pedido = item.pedido;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    item.nomeCliente,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lancha: ${item.nomeEmbarcacao} • ${pedido.horarioPedido}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    pedido.preco,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: _abrirFilaAvaliacao,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PedidoAdminItem {
  final Pedido pedido;
  final String nomeCliente;
  final String nomeEmbarcacao;

  const _PedidoAdminItem({
    required this.pedido,
    required this.nomeCliente,
    required this.nomeEmbarcacao,
  });
}
