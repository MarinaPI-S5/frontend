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
    embarcacao: 'Lancha Ventura 250',
    responsavel: 'Carlos Henrique',
    dono: 'Roberto Almeida',
    qtdItens: 3,
    valor: 1250.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 8, 30),
  ),
  Pedido(
    embarcacao: 'Veleiro Fast 310',
    responsavel: 'Mariana Costa',
    dono: 'Fernanda Oliveira',
    qtdItens: 2,
    valor: 850.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 9, 15),
  ),
  Pedido(
    embarcacao: 'Lancha Focker 255',
    responsavel: 'André Martins',
    dono: 'Ricardo Souza',
    qtdItens: 5,
    valor: 3200.00,
    horarioBrutoPedido: DateTime(2026, 10, 13, 10, 45),
  ),
  Pedido(
    embarcacao: 'Jet Ski Yamaha FX',
    responsavel: 'Lucas Ferreira',
    dono: 'Lucas Ferreira',
    qtdItens: 1,
    valor: 450.00,
    horarioBrutoPedido: DateTime(2026, 10, 12, 14, 20),
  ),
  Pedido(
    embarcacao: 'Lancha Real 275',
    responsavel: 'Juliana Mendes',
    dono: 'Eduardo Mendes',
    qtdItens: 4,
    valor: 2180.00,
    horarioBrutoPedido: DateTime(2026, 10, 12, 16, 10),
  ),
  Pedido(
    embarcacao: 'Veleiro Delta 36',
    responsavel: 'Pedro Henrique',
    dono: 'Ana Beatriz Lima',
    qtdItens: 2,
    valor: 1750.00,
    horarioBrutoPedido: DateTime(2026, 10, 11, 11, 5),
  ),
  Pedido(
    embarcacao: 'Lancha Triton 300',
    responsavel: 'Gabriel Santos',
    dono: 'Marcelo Ribeiro',
    qtdItens: 6,
    valor: 4850.00,
    horarioBrutoPedido: DateTime(2026, 10, 10, 13, 40),
  ),
  Pedido(
    embarcacao: 'Jet Ski Sea-Doo GTX',
    responsavel: 'Camila Rocha',
    dono: 'Patrícia Rocha',
    qtdItens: 3,
    valor: 920.00,
    horarioBrutoPedido: DateTime(2026, 10, 9, 9, 50),
  ),
  Pedido(
    embarcacao: 'Lancha Coral 27',
    responsavel: 'Felipe Carvalho',
    dono: 'Bruno Carvalho',
    qtdItens: 2,
    valor: 1450.00,
    horarioBrutoPedido: DateTime(2026, 10, 8, 15, 25),
  ),
  Pedido(
    embarcacao: 'Lancha Schaefer 303',
    responsavel: 'Rafael Gomes',
    dono: 'Sérgio Gomes',
    qtdItens: 7,
    valor: 5600.00,
    horarioBrutoPedido: DateTime(2026, 10, 7, 8, 5),
  ),
];
