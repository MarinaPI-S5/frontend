import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/utils/xml_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetalhesPedidoScreen extends StatefulWidget {
  final Pedido pedido;
  final String? nomeCliente;
  final String? nomeResponsavel;
  final String? statusTexto;

  const DetalhesPedidoScreen({
    super.key,
    required this.pedido,
    this.nomeCliente,
    this.nomeResponsavel,
    this.statusTexto,
  });

  @override
  State<DetalhesPedidoScreen> createState() => _DetalhesPedidoScreenState();
}

class _DetalhesPedidoScreenState extends State<DetalhesPedidoScreen> {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  final TextEditingController motivoController = TextEditingController();
  bool _enviando = false;
  bool _gerandoXml = false;

  @override
  void initState() {
    super.initState();
    if (widget.pedido.motivo != null &&
        widget.pedido.motivo!.trim().isNotEmpty) {
      motivoController.text = widget.pedido.motivo!.trim();
    }
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red.shade700 : null,
      ),
    );
  }

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

  String _formatarData(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return '-';
    final matchData = RegExp(r'(\d{2}/\d{2}/\d{4})').firstMatch(texto);
    if (matchData != null) return matchData.group(1)!;
    final isoMatch = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
    if (isoMatch != null) {
      return '${isoMatch.group(3)}/${isoMatch.group(2)}/${isoMatch.group(1)}';
    }
    return texto.split(' | ').first;
  }

  String _resolverNomeCliente(Pedido pedido) {
    final candidatos = [
      widget.nomeCliente?.trim() ?? '',
      widget.nomeResponsavel?.trim() ?? '',
      pedido.responsavel.trim(),
      pedido.dono.trim(),
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

  Future<void> _gerarEBaixarXml({
    required Pedido pedido,
    required String nomeCliente,
    required String statusLabel,
  }) async {
    if (_gerandoXml || _enviando) return;

    setState(() => _gerandoXml = true);

    try {
      final idLimpo = (pedido.id?.trim().isNotEmpty ?? false)
          ? pedido.id!.trim()
          : 'pedido';
      final nomeArquivo = 'pedido_$idLimpo.xml';

      final conteudoXml = pedido.toXml(
        nomeClienteOverride: nomeCliente,
        statusOverride: statusLabel,
        motivoOverride: motivoController.text,
      );

      final resultado = await salvarXml(nomeArquivo, conteudoXml);
      mostrarMensagem(resultado);
    } catch (e) {
      mostrarMensagem(
        'Erro ao gerar XML: ${e.toString().replaceFirst('Exception: ', '')}',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _gerandoXml = false);
      }
    }
  }

  Future<void> _enviarRecusa() async {
    if (_enviando || _gerandoXml) return;

    final motivo = motivoController.text.trim();
    if (motivo.isEmpty) {
      mostrarMensagem('Descreva o motivo antes de enviar.', erro: true);
      return;
    }

    final id = widget.pedido.id?.trim() ?? '';
    if (id.isEmpty) {
      mostrarMensagem('ID do pedido não encontrado.', erro: true);
      return;
    }

    setState(() => _enviando = true);

    try {
      final token = SessionStore.current?.token.trim() ?? '';
      final response = await http.put(
        Uri.parse('$_baseUrl/departure/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': 'recusado', 'reason': motivo}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String msg = 'Falha ao negar pedido (${response.statusCode})';
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('motivo_recusa_$id', motivo);

      widget.pedido.status = 'recusado';
      widget.pedido.motivo = motivo;

      if (!mounted) return;
      mostrarMensagem('Pedido negado com sucesso.');
      Navigator.pop(context, true);
    } catch (e) {
      mostrarMensagem(e.toString().replaceFirst('Exception: ', ''), erro: true);
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final nomeClienteExibido = _resolverNomeCliente(pedido);
    final statusLabel = (widget.statusTexto?.trim().isNotEmpty ?? false)
        ? widget.statusTexto!.trim()
        : 'Negado';
    final bloqueado = _enviando || _gerandoXml;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: bloqueado ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do pedido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            nomeClienteExibido,
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
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDADA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Color(0xFFFF5A5F),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _linhaInformacao(
                      'Data',
                      _formatarData(pedido.horarioPedido),
                    ),
                    const SizedBox(height: 14),
                    _linhaInformacao('Responsável', nomeClienteExibido),
                    const SizedBox(height: 14),
                    _linhaInformacao('Valor', pedido.preco),
                    const SizedBox(height: 20),
                    const Text(
                      'Descreva o motivo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: motivoController,
                      enabled: !bloqueado,
                      minLines: 4,
                      maxLines: 5,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite aqui...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF1683FF),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: bloqueado
                                  ? null
                                  : () => _gerarEBaixarXml(
                                      pedido: pedido,
                                      nomeCliente: nomeClienteExibido,
                                      statusLabel: statusLabel,
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1683FF),
                                side: const BorderSide(
                                  color: Color(0xFF1683FF),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _gerandoXml
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF1683FF),
                                      ),
                                    )
                                  : const Text(
                                      'Gerar XML',
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
                            height: 46,
                            child: ElevatedButton(
                              onPressed: bloqueado ? null : _enviarRecusa,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF28964B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _enviando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Enviar',
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linhaInformacao(String titulo, String valor) {
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
