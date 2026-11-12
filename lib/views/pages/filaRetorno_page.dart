import 'package:flutter/material.dart';
import 'package:frontend/models/saida.dart';
import 'package:frontend/views/widgets/retornoCard.dart';

class FilaretornoPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Retornos',
      home: Scaffold(
        appBar: AppBar(title: Text('Fila de Retornos')),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: listaSaidasMock.length,
              itemBuilder: (context, index) {
                final saidaAtual = listaSaidasMock[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Center(child: Retornocard(saida: saidaAtual)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
