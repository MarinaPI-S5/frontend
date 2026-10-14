import 'package:flutter/material.dart';
import 'package:pi5/models/pedido.dart';
import 'package:pi5/views/widgets/pedidoCard.dart';

class Filapedidos extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Agendamentos',
      home: Scaffold(
        appBar: AppBar(title: Text('Fila de agendamentos')),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: listaPedidosMock.length,
              itemBuilder: (context, index) {
                final pedidoAtual = listaPedidosMock[index];
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