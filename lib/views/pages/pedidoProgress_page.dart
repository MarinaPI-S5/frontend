import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/pedido.dart';
import 'package:http/http.dart' as http;

enum EtapaOperacao {
  emAnalise('Em análise', Icons.hourglass_bottom),
  aprovado('Aprovado', Icons.check),
  emEspera('Em espera', Icons.hourglass_full),
  emPreparo('Em preparo', Icons.inventory_2_outlined),
  pronto('Pronto', Icons.check_circle),
  navegando('Navegando', Icons.sailing),
  retornando('Retornando', Icons.directions_boat_filled_outlined),
  encerrado('Encerrado', Icons.verified_outlined);

  final String label;
  final IconData icon;
  const EtapaOperacao(this.label, this.icon);
}

class PedidoProgressPage extends StatefulWidget {
  final Pedido pedido;

  const PedidoProgressPage({super.key, required this.pedido});

  @override
  State<PedidoProgressPage> createState() => _PedidoProgressPageState();
}

class _PedidoProgressPageState extends State<PedidoProgressPage> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  late Pedido _pedidoAtual;
  EtapaOperacao _etapaAtual = EtapaOperacao.emAnalise;
  bool _recusado = false;
  bool _carregandoStatus = false;

  @override
  void initState() {
    super.initState();
    _pedidoAtual = widget.pedido;
    _sincronizarStatusLocal(_pedidoAtual);
    _buscarStatusAtualizado();
  }

  void _sincronizarStatusLocal(Pedido pedido) {
    final dynamic dyn = pedido;
    String rawStatus = '';
    try {
      rawStatus = (dyn.status ?? '').toString().toLowerCase().trim();
    } catch (_) {
      rawStatus = '';
    }

    if (rawStatus == 'rejected' ||
        rawStatus == 'denied' ||
        rawStatus == 'negado' ||
        rawStatus == 'recusado') {
      _recusado = true;
      _etapaAtual = EtapaOperacao.emAnalise;
      return;
    }

    _recusado = false;
    _etapaAtual = _mapearStatusParaEtapa(rawStatus);
  }

  EtapaOperacao _mapearStatusParaEtapa(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'approved':
      case 'aprovado':
        return EtapaOperacao.aprovado;
      case 'waiting':
      case 'em_espera':
      case 'em espera':
        return EtapaOperacao.emEspera;
      case 'preparing':
      case 'em_preparo':
      case 'em preparo':
        return EtapaOperacao.emPreparo;
      case 'ready':
      case 'pronto':
        return EtapaOperacao.pronto;
      case 'sailing':
      case 'navigating':
      case 'navegando':
        return EtapaOperacao.navegando;
      case 'returning':
      case 'retornando':
        return EtapaOperacao.retornando;
      case 'finished':
      case 'completed':
      case 'encerrado':
        return EtapaOperacao.encerrado;
      default:
        return EtapaOperacao.emAnalise;
    }
  }

  String _mapearEtapaParaStatusApi(EtapaOperacao etapa) {
    switch (etapa) {
      case EtapaOperacao.emAnalise:
        return 'analise';
      case EtapaOperacao.aprovado:
        return 'aprovado';
      case EtapaOperacao.emEspera:
        return 'em espera';
      case EtapaOperacao.emPreparo:
        return 'em preparo';
      case EtapaOperacao.pronto:
        return 'em preparo';
      case EtapaOperacao.navegando:
        return 'retornando';
      case EtapaOperacao.retornando:
        return 'retornando';
      case EtapaOperacao.encerrado:
        return 'encerrado';
    }
  }

  Future<void> _buscarStatusAtualizado() async {
    final id = _pedidoAtual.id?.trim() ?? '';
    if (id.isEmpty) return;

    final token = SessionStore.current?.token.trim() ?? '';
    if (mounted) {
      setState(() => _carregandoStatus = true);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/departure/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic>? data = decoded is Map<String, dynamic>
            ? (decoded['data'] is Map<String, dynamic>
                  ? decoded['data'] as Map<String, dynamic>
                  : decoded)
            : null;

        if (data != null && mounted) {
          final atualizado = Pedido.fromJson(data);
          final statusStr = (data['status'] ?? '').toString();
          setState(() {
            _pedidoAtual = atualizado;
            if (statusStr.isNotEmpty) {
              final s = statusStr.toLowerCase().trim();
              if (s == 'rejected' ||
                  s == 'denied' ||
                  s == 'negado' ||
                  s == 'recusado') {
                _recusado = true;
              } else {
                _recusado = false;
                _etapaAtual = _mapearStatusParaEtapa(s);
              }
            }
          });
        }
      }
    } catch (_) {
      // Mantém estado atual em caso de falha de rede
    } finally {
      if (mounted) {
        setState(() => _carregandoStatus = false);
      }
    }
  }

  Future<void> _atualizarStatusNoBackend(EtapaOperacao novaEtapa) async {
    final id = _pedidoAtual.id?.trim() ?? '';
    if (id.isEmpty) {
      setState(() {
        _recusado = false;
        _etapaAtual = novaEtapa;
      });
      return;
    }

    final token = SessionStore.current?.token.trim() ?? '';
    final statusApi = _mapearEtapaParaStatusApi(novaEtapa);

    final response = await http.put(
      Uri.parse('$_baseUrl/departure/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': statusApi}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Erro ao atualizar etapa (${response.statusCode})';
      if (response.body.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
      }
      throw Exception(msg);
    }

    if (mounted) {
      setState(() {
        _recusado = false;
        _etapaAtual = novaEtapa;
      });
    }
  }

  Future<void> _iniciarPasseio() async {
    try {
      await _atualizarStatusNoBackend(EtapaOperacao.navegando);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passeio iniciado! Status: Navegando.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _avancarEtapaAdmin() async {
    final etapas = EtapaOperacao.values;
    final proximoIndex = _etapaAtual.index + 1;
    if (proximoIndex >= etapas.length) return;

    try {
      await _atualizarStatusNoBackend(etapas[proximoIndex]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  String _textoBadgeStatus() {
    if (_recusado) return 'Recusado';
    if (_etapaAtual == EtapaOperacao.encerrado) return 'Encerrado';
    return 'Em andamento';
  }

  Color _corFundoBadge() {
    if (_recusado) return const Color(0xFFFFDADA);
    if (_etapaAtual == EtapaOperacao.encerrado) return const Color(0xFFE7F4EC);
    return const Color(0xFFFFF3E0);
  }

  Color _corTextoBadge() {
    if (_recusado) return const Color(0xFFE53950);
    if (_etapaAtual == EtapaOperacao.encerrado) return const Color(0xFF1E8E4E);
    return const Color(0xFFEF6C00);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = SessionStore.current?.user.isAdmin ?? false;
    final podeDeslizar =
        !_recusado && (isAdmin || _etapaAtual == EtapaOperacao.pronto);

    final nomeEmbarcacao = _pedidoAtual.embarcacao.trim().isNotEmpty
        ? _pedidoAtual.embarcacao.trim()
        : 'Embarcação';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Status do Pedido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _carregandoStatus ? null : _buscarStatusAtualizado,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _buscarStatusAtualizado,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            nomeEmbarcacao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _corFundoBadge(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _textoBadgeStatus(),
                            style: TextStyle(
                              color: _corTextoBadge(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    SlideIniciarPasseioWidget(
                      habilitado: podeDeslizar,
                      onIniciarPasseio: _iniciarPasseio,
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: _etapaAtual == EtapaOperacao.encerrado
                                ? null
                                : _avancarEtapaAdmin,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Avançar Etapa'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final etapas = EtapaOperacao.values;

    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Column(
        children: List.generate(etapas.length, (index) {
          final etapa = etapas[index];
          final concluidaOuAtual = !_recusado && index <= _etapaAtual.index;
          final temProximo = index < etapas.length - 1;
          final linhaAtiva = !_recusado && index < _etapaAtual.index;

          final corCirculo = concluidaOuAtual
              ? const Color(0xFF16A34A)
              : const Color(0xFFD1D5DB);
          final corIcone = concluidaOuAtual
              ? const Color(0xFF052E16)
              : const Color(0xFF6B7280);
          final corTexto = concluidaOuAtual
              ? const Color(0xFF16A34A)
              : const Color(0xFF9CA3AF);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: corCirculo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(etapa.icon, color: corIcone, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    etapa.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: corTexto,
                    ),
                  ),
                ],
              ),
              if (temProximo)
                Container(
                  margin: const EdgeInsets.only(left: 19),
                  width: 2,
                  height: 22,
                  color: linhaAtiva
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE5E7EB),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class SlideIniciarPasseioWidget extends StatefulWidget {
  final bool habilitado;
  final Future<void> Function() onIniciarPasseio;

  const SlideIniciarPasseioWidget({
    super.key,
    required this.habilitado,
    required this.onIniciarPasseio,
  });

  @override
  State<SlideIniciarPasseioWidget> createState() =>
      _SlideIniciarPasseioWidgetState();
}

class _SlideIniciarPasseioWidgetState extends State<SlideIniciarPasseioWidget> {
  double _dragX = 0;
  bool _enviando = false;

  void _resetarSlide() {
    if (!mounted) return;
    setState(() {
      _dragX = 0;
      _enviando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final podeInteragir = widget.habilitado && !_enviando;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double altura = 58;
        const double thumbSize = 46;
        const double paddingHorizontal = 6;
        final double maxDrag =
            (constraints.maxWidth - thumbSize - (paddingHorizontal * 2)).clamp(
              0.0,
              double.infinity,
            );

        return Opacity(
          opacity: podeInteragir ? 1.0 : 0.45,
          child: Container(
            height: altura,
            padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
            decoration: BoxDecoration(
              color: podeInteragir
                  ? const Color(0xFFE7F4EC)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(altura / 2),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Text(
                    podeInteragir
                        ? 'Deslize para iniciar passeio'
                        : 'Aguardando status Pronto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: podeInteragir
                          ? const Color(0xFF1E8E4E)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Positioned(
                  left: _dragX.clamp(0.0, maxDrag),
                  child: GestureDetector(
                    onHorizontalDragUpdate: !podeInteragir
                        ? null
                        : (details) {
                            setState(() {
                              _dragX = (_dragX + details.delta.dx).clamp(
                                0.0,
                                maxDrag,
                              );
                            });
                          },
                    onHorizontalDragEnd: !podeInteragir
                        ? null
                        : (_) async {
                            if (maxDrag > 0 && _dragX >= maxDrag * 0.75) {
                              setState(() {
                                _dragX = maxDrag;
                                _enviando = true;
                              });
                              try {
                                await widget.onIniciarPasseio();
                              } finally {
                                _resetarSlide();
                              }
                            } else {
                              setState(() => _dragX = 0);
                            }
                          },
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: podeInteragir
                            ? const Color(0xFF1E8E4E)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: _enviando
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.directions_boat,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
