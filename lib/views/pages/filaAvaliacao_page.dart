import 'package:flutter/material.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/widgets/pedidoCard.dart';

class FilaavaliacaoPage extends StatelessWidget {
  const FilaavaliacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Pedidos Para Avaliação',
      home: Scaffold(
        appBar: AppBar(title: Text('Fila de pedidos para avaliação')),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: Pedido.listaPedidosMock.length,
              itemBuilder: (context, index) {
                final pedidoAtual = Pedido.listaPedidosMock[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Center(child: PedidoCard(pedido: pedidoAtual)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
