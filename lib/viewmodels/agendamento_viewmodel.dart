import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/repositores/embarcacao_repository.dart';
import 'package:frontend/data/session/pedido_store.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';
import 'package:frontend/models/embarcacao.dart';
import 'package:frontend/models/pedido.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ItemPedido {
  final String nome;
  final double preco;
  bool selecionado;
  int quantidade;

  ItemPedido({
    required this.nome,
    required this.preco,
    this.selecionado = false,
    this.quantidade = 1,
  });
}

class AgendamentoViewModel {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

  final EmbarcacaoRepository _embarcacaoRepository;

  AgendamentoViewModel({EmbarcacaoRepository? embarcacaoRepository})
    : _embarcacaoRepository = embarcacaoRepository ?? EmbarcacaoRepository();

  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final ValueNotifier<String> proprietarioNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<EmbarcacaoCadastrada>> embarcacoesNotifier =
      ValueNotifier<List<EmbarcacaoCadastrada>>([]);
  final ValueNotifier<EmbarcacaoCadastrada?> embarcacaoSelecionadaNotifier =
      ValueNotifier<EmbarcacaoCadastrada?>(null);
  final ValueNotifier<bool> isLoadingEmbarcacoesNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<String?> erroEmbarcacoesNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<List<Pedido>> pedidosSalvosNotifier =
      ValueNotifier<List<Pedido>>([]);

  final List<ItemPedido> itensDisponiveis = [
    ItemPedido(nome: 'Gelo', preco: 10.00),
    ItemPedido(nome: 'Carvão', preco: 25.00),
    ItemPedido(nome: 'Água', preco: 6.00),
    ItemPedido(nome: 'Refrigerante', preco: 8.50),
    ItemPedido(nome: 'Cerveja', preco: 6.00),
    ItemPedido(nome: 'Gasolina', preco: 6.50),
  ];

  Future<void> carregarDadosIniciais() async {
    erroEmbarcacoesNotifier.value = null;

    final AuthSession? session = SessionStore.current;
    final clienteId = session?.user.id.trim() ?? '';
    final emailCliente = session?.user.email.trim() ?? '';

    if (clienteId.isEmpty) {
      proprietarioNotifier.value = emailCliente;
      embarcacoesNotifier.value = [];
      embarcacaoSelecionadaNotifier.value = null;
      return;
    }

    isLoadingEmbarcacoesNotifier.value = true;
    try {
      final lista = await _embarcacaoRepository.listarEmbarcacoesPorCliente(
        clienteId,
      );
      embarcacoesNotifier.value = lista;

      if (lista.isNotEmpty) {
        final primeira = lista.first;
        embarcacaoSelecionadaNotifier.value = primeira;
        proprietarioNotifier.value = primeira.dono.trim().isNotEmpty
            ? primeira.dono.trim()
            : emailCliente;
      } else {
        embarcacaoSelecionadaNotifier.value = null;
        proprietarioNotifier.value = emailCliente;
      }
    } catch (e) {
      erroEmbarcacoesNotifier.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      proprietarioNotifier.value = emailCliente;
      embarcacoesNotifier.value = [];
      embarcacaoSelecionadaNotifier.value = null;
    } finally {
      isLoadingEmbarcacoesNotifier.value = false;
    }
  }

  void selecionarEmbarcacao(EmbarcacaoCadastrada? embarcacao) {
    embarcacaoSelecionadaNotifier.value = embarcacao;
    if (embarcacao != null && embarcacao.dono.trim().isNotEmpty) {
      proprietarioNotifier.value = embarcacao.dono.trim();
    }
  }

  Future<Pedido?> concluirAgendamento({
    required String proprietario,
    required String responsavel,
    required String dataTexto,
  }) async {
    final embarcacaoAtual = embarcacaoSelecionadaNotifier.value;
    if (embarcacaoAtual == null) return null;

    final session = SessionStore.current;
    final clienteId = session?.user.id.trim() ?? '';
    final token = session?.token.trim() ?? '';
    final emailUsuario = session?.user.email.trim() ?? '';

    final dataParseada = _parseData(dataTexto) ?? DateTime.now();

    int totalQtdItens = 0;
    final List<dynamic> itensPayload = [];
    for (final item in itensDisponiveis) {
      if (item.selecionado) {
        totalQtdItens += item.quantidade;
        itensPayload.add({'name': item.nome, 'quantity': item.quantidade});
      }
    }

    final responsavelLimpo = responsavel.trim();
    final responsibleEmail = responsavelLimpo.contains('@')
        ? responsavelLimpo
        : emailUsuario;

    final bodyMap = {
      'client': clienteId,
      'responsibleEmail': responsibleEmail,
      'boat': embarcacaoAtual.id ?? embarcacaoAtual.embarcacao,
      'date': dataParseada.toUtc().toIso8601String(),
      'price': valorTotal,
      'status': 'analise',
      'items': itensPayload,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/departure'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    Pedido pedidoBase;
    if (response.body.trim().isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final rawPedido = decoded['data'] is Map
            ? decoded['data']
            : (decoded['departure'] is Map ? decoded['departure'] : decoded);
        pedidoBase = Pedido.fromJson(
          Map<String, dynamic>.from(rawPedido as Map),
        );
      } else {
        pedidoBase = _montarPedidoLocal(
          embarcacaoAtual: embarcacaoAtual,
          proprietario: proprietario,
          responsavel: responsavelLimpo,
          totalQtdItens: totalQtdItens,
          horarioPedido: DateTime.now(),
        );
      }
    } else {
      pedidoBase = _montarPedidoLocal(
        embarcacaoAtual: embarcacaoAtual,
        proprietario: proprietario,
        responsavel: responsavelLimpo,
        totalQtdItens: totalQtdItens,
        horarioPedido: DateTime.now(),
      );
    }

    final pedidoCriado = Pedido(
      id: pedidoBase.id ?? embarcacaoAtual.id,
      clientId:
          pedidoBase.clientId ?? (clienteId.isNotEmpty ? clienteId : null),
      embarcacao: embarcacaoAtual.embarcacao,
      dono: proprietario.trim().isNotEmpty
          ? proprietario.trim()
          : (pedidoBase.dono.isNotEmpty
                ? pedidoBase.dono
                : embarcacaoAtual.dono),
      telefone: pedidoBase.telefone.isNotEmpty
          ? pedidoBase.telefone
          : embarcacaoAtual.telefone,
      responsavel: responsavelLimpo.isNotEmpty
          ? responsavelLimpo
          : pedidoBase.responsavel,
      qtdItens: pedidoBase.qtdItens > 0 ? pedidoBase.qtdItens : totalQtdItens,
      valor: pedidoBase.valor > 0 ? pedidoBase.valor : valorTotal,
      horarioBrutoPedido: DateTime.now(),
      status: pedidoBase.status,
    );

    await PedidoStore.adicionar(
      pedidoCriado,
      userId: clienteId.isNotEmpty ? clienteId : null,
    );
    pedidosSalvosNotifier.value = [
      ...pedidosSalvosNotifier.value,
      pedidoCriado,
    ];
    return pedidoCriado;
  }

  Pedido _montarPedidoLocal({
    required EmbarcacaoCadastrada embarcacaoAtual,
    required String proprietario,
    required String responsavel,
    required int totalQtdItens,
    required DateTime horarioPedido,
  }) {
    return Pedido(
      id: embarcacaoAtual.id,
      embarcacao: embarcacaoAtual.embarcacao,
      dono: proprietario.trim().isNotEmpty
          ? proprietario.trim()
          : embarcacaoAtual.dono,
      telefone: embarcacaoAtual.telefone,
      responsavel: responsavel,
      qtdItens: totalQtdItens,
      valor: valorTotal,
      horarioBrutoPedido: horarioPedido,
      status: 'analise',
    );
  }

  DateTime? _parseData(String value) {
    final partes = value.split('/');
    if (partes.length != 3) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
    final agora = DateTime.now();
    return DateTime(ano, mes, dia, agora.hour, agora.minute);
  }

  String? validateProprietario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome do proprietário';
    }
    return null;
  }

  String? validateResponsavel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o responsável';
    }
    return null;
  }

  String? validateEmbarcacao(EmbarcacaoCadastrada? embarcacao) {
    if (embarcacao == null || embarcacao.embarcacao.trim().isEmpty) {
      return 'Selecione uma embarcação';
    }
    return null;
  }

  String? validateData(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a data do agendamento';
    }
    if (value.length < 10) {
      return 'Digite uma data válida (DD/MM/AAAA)';
    }
    return null;
  }

  void toggleItemSelecao(ItemPedido item, bool? valor) {
    item.selecionado = valor ?? false;
  }

  void incrementarQuantidade(ItemPedido item) {
    item.quantidade++;
  }

  void decrementarQuantidade(ItemPedido item) {
    if (item.quantidade > 1) {
      item.quantidade--;
    }
  }

  double get valorTotal {
    double total = 0.0;
    for (var item in itensDisponiveis) {
      if (item.selecionado) {
        total += item.preco * item.quantidade;
      }
    }
    return total;
  }

  void dispose() {
    proprietarioNotifier.dispose();
    embarcacoesNotifier.dispose();
    embarcacaoSelecionadaNotifier.dispose();
    isLoadingEmbarcacoesNotifier.dispose();
    erroEmbarcacoesNotifier.dispose();
    pedidosSalvosNotifier.dispose();
  }
}
