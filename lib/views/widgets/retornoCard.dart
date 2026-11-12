import 'package:flutter/material.dart';
import 'package:frontend/models/saida.dart';
import 'package:frontend/views/widgets/messageButton.dart';
import 'package:frontend/views/widgets/statusBadge.dart';

class Retornocard extends StatelessWidget {
  final Saida saida;

  const Retornocard({super.key, required this.saida});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    saida.embarcacao,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusBadge(concluido: saida.horarioRetorno != "--:--"),
                ],
              ),

              _linha('Responsavel', saida.responsavel),

              _linha('Dono', saida.dono),

              _linha('Horario de saída', saida.horarioSaida.toString()),

              _linha(
                'Horario de retorno previsto',
                saida.horarioPrevisto.toString(),
              ),

              _linha(
                'Horario de retorno efetivo',
                saida.horarioRetorno.toString(),
              ),

              _linha("Telefone", saida.telefone),

              SizedBox(width: 6),

              Messagebutton(),
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
