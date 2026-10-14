import 'package:flutter/material.dart';
import 'package:frontend/models/pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const PedidoCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          children: [
            Text(
              pedido.embarcacao,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: const Text(
                    'Quantidade de itens',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${pedido.qtdItens}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: const Text(
                    'Preço',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 5,
                  child: Text(
                    pedido.preco,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: const Text(
                    'Responsável',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 5,
                  child: Text(
                    pedido.responsavel,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: const Text(
                    'Data e hora',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 5,
                  child: Text(
                    pedido.horarioPedido,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
