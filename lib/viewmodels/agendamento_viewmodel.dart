import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/repositores/embarcacao_repository.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/auth_session.dart';
import 'package:frontend/models/embarcacao.dart';
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
  final EmbarcacaoRepository _embarcacaoRepository;

  AgendamentoViewModel({EmbarcacaoRepository? embarcacaoRepository})
    : _embarcacaoRepository = embarcacaoRepository ?? EmbarcacaoRepository();

  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Estados reativos para proprietário, embarcações e carregamento
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

  // Opção de adicionar produtos e calcular valor total (intacta)
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

  // Validações dos campos de texto
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
  }
}
