import 'package:frontend/models/embarcacao.dart';
import 'package:intl/intl.dart';

class Pedido {
  String embarcacao;
  String responsavel;
  String dono;
  int qtdItens;
  double valor;
  DateTime horarioBrutoPedido;

  Pedido({
    required this.embarcacao,
    required this.responsavel,
    required this.dono,
    required this.qtdItens,
    required this.valor,
    required this.horarioBrutoPedido,
  });

  String get preco {
    final formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    return formatador.format(valor);
  }

  String get horarioPedido {
    final formatador = DateFormat('dd/MM/yyyy | HH:mm');

    return formatador.format(horarioBrutoPedido);
  }
}

final List<Pedido> listaPedidosMock = [
  Pedido(
    embarcacao: listaEmbarcacoesMock[0].embarcacao,
    responsavel: 'Carlos Henrique',
    dono: listaEmbarcacoesMock[0].dono,
    qtdItens: 3,
    valor: 1250.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 8, 30),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[1].embarcacao,
    responsavel: 'Mariana Costa',
    dono: listaEmbarcacoesMock[1].dono,
    qtdItens: 2,
    valor: 850.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 9, 15),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[2].embarcacao,
    responsavel: 'André Martins',
    dono: listaEmbarcacoesMock[2].dono,
    qtdItens: 5,
    valor: 3200.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 10, 45),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[3].embarcacao,
    responsavel: 'Lucas Ferreira',
    dono: listaEmbarcacoesMock[3].dono,
    qtdItens: 1,
    valor: 450.00,
    horarioBrutoPedido: DateTime(2026, 10, 12, 14, 20),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[4].embarcacao,
    responsavel: 'Juliana Mendes',
    dono: listaEmbarcacoesMock[4].dono,
    qtdItens: 4,
    valor: 2180.00,
    horarioBrutoPedido: DateTime(2026, 10, 12, 16, 10),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[5].embarcacao,
    responsavel: 'Pedro Henrique',
    dono: listaEmbarcacoesMock[5].dono,
    qtdItens: 2,
    valor: 1750.00,
    horarioBrutoPedido: DateTime(2026, 10, 11, 11, 5),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[6].embarcacao,
    responsavel: 'Gabriel Santos',
    dono: listaEmbarcacoesMock[6].dono,
    qtdItens: 6,
    valor: 4850.00,
    horarioBrutoPedido: DateTime(2026, 10, 10, 13, 40),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[7].embarcacao,
    responsavel: 'Camila Rocha',
    dono: listaEmbarcacoesMock[7].dono,
    qtdItens: 3,
    valor: 920.00,
    horarioBrutoPedido: DateTime(2026, 10, 9, 9, 50),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[8].embarcacao,
    responsavel: 'Felipe Carvalho',
    dono: listaEmbarcacoesMock[8].dono,
    qtdItens: 2,
    valor: 1450.00,
    horarioBrutoPedido: DateTime(2026, 10, 8, 15, 25),
  ),
  Pedido(
    embarcacao: listaEmbarcacoesMock[9].embarcacao,
    responsavel: 'Rafael Gomes',
    dono: listaEmbarcacoesMock[9].dono,
    qtdItens: 7,
    valor: 5600.00,
    horarioBrutoPedido: DateTime(2026, 10, 7, 8, 5),
  ),
];
