import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/detalhePedidos.dart';
import 'package:http/http.dart' as http;

class PedidoCard extends StatefulWidget {
  final Pedido pedido;
  final String? nomeCliente;
  final String? nomeResponsavel;
  final Future<void> Function()? onDeny;
  final Future<void> Function()? onAllow;
  final VoidCallback? onUpdated;

  const PedidoCard({
    super.key,
    required this.pedido,
    this.nomeCliente,
    this.nomeResponsavel,
    this.onDeny,
    this.onAllow,
    this.onUpdated,
  });

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  static const String _statusPermitir = 'aprovado';

  bool _isPermitindo = false;

  bool _pareceEmail(String valor) {
    final v = valor.trim();
    return v.contains('@') && v.contains('.');
  }

  bool _valorInvalido(String valor) {
    final v = valor.trim().toLowerCase();
    return v.isEmpty || v == 'string' || v == 'null' || v == 'undefined';
  }

  String _nomeAPartirDeEmail(String email) {
    final parteLocal = email.split('@').first.trim();
    if (parteLocal.isEmpty) return 'Cliente';
    final palavras = parteLocal
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .toList();
    return palavras.isEmpty ? 'Cliente' : palavras.join(' ');
  }

  String _formatarDataCurta(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return '-';
    final matchData = RegExp(r'(\d{2}/\d{2}/\d{4})').firstMatch(texto);
    if (matchData != null) return matchData.group(1)!;
    final isoMatch = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
    if (isoMatch != null) {
      return '${isoMatch.group(3)}/${isoMatch.group(2)}/${isoMatch.group(1)}';
    }
    return texto;
  }

  String _resolverNomeCliente() {
    final candidatos = [
      widget.nomeCliente?.trim() ?? '',
      widget.nomeResponsavel?.trim() ?? '',
      widget.pedido.responsavel.trim(),
    ];

    for (final c in candidatos) {
      if (!_valorInvalido(c) && !_pareceEmail(c)) {
        return c;
      }
    }

    for (final c in candidatos) {
      if (!_valorInvalido(c) && _pareceEmail(c)) {
        return _nomeAPartirDeEmail(c);
      }
    }

    return 'Cliente';
  }

  Future<void> _abrirTelaNegar() async {
    if (_isPermitindo) return;

    if (widget.onDeny != null) {
      await widget.onDeny!();
      if (mounted) widget.onUpdated?.call();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPedidoScreen(
          pedido: widget.pedido,
          nomeCliente: _resolverNomeCliente(),
          nomeResponsavel: _resolverNomeCliente(),
          statusTexto: 'Negado',
        ),
      ),
    );

    if (mounted) {
      widget.onUpdated?.call();
    }
  }

  Future<void> _permitirPedido() async {
    if (_isPermitindo) return;

    setState(() {
      _isPermitindo = true;
    });

    try {
      if (widget.onAllow != null) {
        await widget.onAllow!();
      } else {
        final id = widget.pedido.id?.trim() ?? '';
        if (id.isEmpty) {
          throw Exception('ID do pedido não encontrado.');
        }

        final token = SessionStore.current?.token.trim() ?? '';
        final response = await http.put(
          Uri.parse('$_baseUrl/departure/$id'),
          headers: {
            'Content-Type': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'status': _statusPermitir}),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          String mensagemErro =
              'Falha ao aprovar pedido (${response.statusCode})';
          if (response.body.trim().isNotEmpty) {
            try {
              final decoded = jsonDecode(response.body);
              if (decoded is Map && decoded['message'] != null) {
                mensagemErro = decoded['message'].toString();
              }
            } catch (_) {}
          }
          throw Exception(mensagemErro);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido aprovado! Status atualizado para Aprovado.'),
        ),
      );
      widget.onUpdated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPermitindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = SessionStore.current?.user.isAdmin ?? false;
    final dataFormatada = _formatarDataCurta(widget.pedido.horarioPedido);
    final nomeExibido = _resolverNomeCliente();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _isPermitindo
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesPedidoScreen(
                        pedido: widget.pedido,
                        nomeCliente: nomeExibido,
                        nomeResponsavel: nomeExibido,
                      ),
                    ),
                  );
                  widget.onUpdated?.call();
                },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeExibido,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _linha('Data', dataFormatada),
                const SizedBox(height: 12),
                _linha('Responsável', nomeExibido),
                const SizedBox(height: 12),
                _linha('Valor', widget.pedido.preco),
                if (isAdmin) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isPermitindo ? null : _abrirTelaNegar,
                            child: const Text(
                              'Negar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8E4E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isPermitindo ? null : _permitirPedido,
                            child: _isPermitindo
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Permitir',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _linha(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
