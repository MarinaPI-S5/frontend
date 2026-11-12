import 'package:flutter/material.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/detalhePedidos.dart';
import 'package:frontend/views/widgets/denyAllowRow.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const PedidoCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesPedidoScreen(pedido: pedido),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              Text(
                pedido.embarcacao,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _linha('Quantidade de itens', pedido.qtdItens.toString()),

              _linha('Preço', pedido.preco),

              _linha('Responsável', pedido.responsavel),

              _linha('Data e hora', pedido.horarioPedido),

              SizedBox(width: 6),

              //**********BOTÕES PARA ADM APROVAR OU NÃO O PEDIDO***********
              //if(User.isAdmin) Denyallowrow(),
            ],
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
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
