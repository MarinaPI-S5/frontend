import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/pedido_store.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/pages/agendamento_page.dart';
import 'package:frontend/views/pages/cadastroCliente_page.dart';
import 'package:frontend/views/pages/cadastroEmbarcacao_page.dart';
import 'package:frontend/views/pages/pedidoProgress_page.dart';
import 'package:frontend/views/widgets/navbarCard.dart';
import 'package:http/http.dart' as http;

class HomeClientePage extends StatefulWidget {
  const HomeClientePage({super.key});

  @override
  State<HomeClientePage> createState() => _HomeClientePageState();
}

class _HomeClientePageState extends State<HomeClientePage> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  bool _isLoadingPedidos = false;
  String? _erroPedidos;
  String? _ultimoUsuarioCarregado;

  @override
  void initState() {
    super.initState();
    SessionStore.notifier.addListener(_onSessionChanged);
    _carregarHistoricoCliente(forcar: true);
  }

  @override
  void dispose() {
    SessionStore.notifier.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    final session = SessionStore.current;
    final chaveAtual = _chaveUsuario(session);
    if (chaveAtual != _ultimoUsuarioCarregado) {
      _carregarHistoricoCliente(forcar: true);
    }
  }

  String? _chaveUsuario(AuthSession? session) {
    if (session == null) return null;
    final id = session.user.id.trim();
    if (id.isNotEmpty) return id;
    final email = session.user.email.trim().toLowerCase();
    return email.isNotEmpty ? email : null;
  }

  Future<void> _carregarHistoricoCliente({bool forcar = false}) async {
    final session = SessionStore.current;
    final userId = session?.user.id.trim() ?? '';
    final token = session?.token.trim() ?? '';
    final chave = _chaveUsuario(session);

    if (chave == null) {
      PedidoStore.limpar();
      if (mounted) {
        setState(() {
          _ultimoUsuarioCarregado = null;
          _erroPedidos = null;
          _isLoadingPedidos = false;
        });
      }
      return;
    }

    if (!forcar && _ultimoUsuarioCarregado == chave && !_isLoadingPedidos) {
      return;
    }

    await PedidoStore.carregarDoCacheUsuario(chave);

    if (userId.isEmpty) {
      _ultimoUsuarioCarregado = chave;
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingPedidos = true;
        _erroPedidos = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/departure/client/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 400 || response.statusCode == 404) {
        if (PedidoStore.notifier.value.isEmpty) {
          await PedidoStore.definirPedidosUsuario(chave, []);
        }
        _ultimoUsuarioCarregado = chave;
        return;
      }

      if (response.statusCode == 403) {
        _ultimoUsuarioCarregado = chave;
        if (mounted && PedidoStore.notifier.value.isEmpty) {
          setState(() {
            _erroPedidos =
                'Sem permissão (403) para consultar o histórico no servidor.';
          });
        }
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Erro ao carregar histórico (${response.statusCode})');
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

      final pedidosDoCliente = listaBruta
          .whereType()
          .map((item) => Pedido.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      if (pedidosDoCliente.isNotEmpty) {
        await PedidoStore.definirPedidosUsuario(chave, pedidosDoCliente);
      } else if (PedidoStore.notifier.value.isEmpty) {
        await PedidoStore.definirPedidosUsuario(chave, []);
      }

      _ultimoUsuarioCarregado = chave;
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

  Future<void> _abrirAgendamento() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgendamentoPage()),
    );
    if (mounted) {
      await _carregarHistoricoCliente(forcar: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _carregarHistoricoCliente(forcar: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

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
                      ValueListenableBuilder<AuthSession?>(
                        valueListenable: SessionStore.notifier,
                        builder: (context, session, _) {
                          final isAdmin = session?.user.isAdmin ?? false;

                          return Row(
                            children: [
                              Expanded(
                                child: _buildActionCard(
                                  context: context,
                                  icon: isAdmin
                                      ? Icons.assignment_turned_in
                                      : Icons.sailing,
                                  color: Colors.green,
                                  title: 'Cadastrar\nEmbarcação',
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionCard(
                                  context: context,
                                  icon: isAdmin
                                      ? Icons.fact_check
                                      : Icons.directions_boat,
                                  color: Colors.blue,
                                  title: 'Novo\nPedido',
                                  onTap: _abrirAgendamento,
                                ),
                              ),
                            ],
                          );
                        },
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
                      child: ValueListenableBuilder<List<Pedido>>(
                        valueListenable: PedidoStore.notifier,
                        builder: (context, pedidos, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Histórico de Pedidos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _isLoadingPedidos
                                        ? null
                                        : () => _carregarHistoricoCliente(
                                            forcar: true,
                                          ),
                                    icon: const Icon(Icons.refresh, size: 20),
                                    tooltip: 'Atualizar histórico',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_isLoadingPedidos && pedidos.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              else if (_erroPedidos != null && pedidos.isEmpty)
                                Text(
                                  _erroPedidos!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                )
                              else if (pedidos.isEmpty)
                                const Text(
                                  'Nenhum pedido realizado ainda.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pedidos.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 12),
                                  itemBuilder: (context, index) {
                                    final pedido = pedidos[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.receipt_long,
                                        color: Colors.blue,
                                      ),
                                      title: Text(
                                        pedido.embarcacao,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Resp.: ${pedido.responsavel} • ${pedido.horarioPedido}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: Text(
                                        pedido.preco,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PedidoProgressPage(
                                              pedido: pedido,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          );
                        },
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
      bottomNavigationBar: ValueListenableBuilder<AuthSession?>(
        valueListenable: SessionStore.notifier,
        builder: (context, session, child) {
          final isLoggedIn = session != null;

          return CustomBottomNav(
            selectedIndex: 0,
            isLoggedIn: isLoggedIn,
            onDestinationSelected: (index) {
              if (isLoggedIn) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroembarcacaoPage(),
                    ),
                  );
                } else if (index == 2) {
                  _abrirAgendamento();
                }
              } else {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroclientePage(),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroembarcacaoPage(),
                    ),
                  );
                } else if (index == 3) {
                  _abrirAgendamento();
                }
              }
            },
          );
        },
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
