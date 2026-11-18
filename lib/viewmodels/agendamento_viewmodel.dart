import 'package:flutter/services.dart';
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
  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final List<ItemPedido> itensDisponiveis = [
    ItemPedido(nome: 'Gelo', preco: 10.00),
    ItemPedido(nome: 'Carvão', preco: 25.00),
    ItemPedido(nome: 'Água', preco: 6.00),
    ItemPedido(nome: 'Refrigerante', preco: 8.50),
    ItemPedido(nome: 'Cerveja', preco: 6.00),
    ItemPedido(nome: 'Gasolina', preco: 6.50),
  ];

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

  String? validateEmbarcacao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome da embarcação';
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
}
