import 'package:flutter/material.dart';
import 'package:frontend/models/etapaStatus.dart';

class TimelineStatusVertical extends StatelessWidget {
  final StatusPedido statusAtual;
  final Color corAtiva;
  final Color corInativa;
  final Color corRecusado;
  final double tamanhoCirculo;
  final double espacamentoVertical;

  const TimelineStatusVertical({
    super.key,
    required this.statusAtual,
    this.corAtiva = const Color(0xFF1DB954),
    this.corInativa = const Color.fromARGB(255, 207, 207, 207),
    this.corRecusado = const Color(0xFFE53935),
    this.tamanhoCirculo = 44.0,
    this.espacamentoVertical = 32.0,
  });

  List<EtapaStatus> _obterEtapasVisiveis() {
    final bool isRecusado = statusAtual == StatusPedido.recusado;

    return [
      const EtapaStatus(
        status: StatusPedido.emAnalise,
        titulo: 'Em análise',
        icone: Icons.hourglass_empty,
      ),
      if (isRecusado)
        const EtapaStatus(
          status: StatusPedido.recusado,
          titulo: 'Recusado',
          icone: Icons.close,
        )
      else ...[
        const EtapaStatus(
          status: StatusPedido.aprovado,
          titulo: 'Aprovado',
          icone: Icons.check,
        ),
        const EtapaStatus(
          status: StatusPedido.emEspera,
          titulo: 'Em espera',
          icone: Icons.hourglass_bottom,
        ),
        const EtapaStatus(
          status: StatusPedido.emPreparo,
          titulo: 'Em preparo',
          icone: Icons.inventory_2_outlined,
        ),

        const EtapaStatus(
          status: StatusPedido.pronto,
          titulo: 'Pronto',
          icone: Icons.check_circle,
        ),
        const EtapaStatus(
          status: StatusPedido.navegando,
          titulo: 'Navegando',
          icone: Icons.sailing,
        ),
        const EtapaStatus(
          status: StatusPedido.retornando,
          titulo: 'Retornando',
          icone: Icons.directions_boat_outlined,
        ),
        const EtapaStatus(
          status: StatusPedido.encerrado,
          titulo: 'Encerrado',
          icone: Icons.verified_outlined,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final etapasVisiveis = _obterEtapasVisiveis();
    final int indiceAtual = etapasVisiveis
        .indexWhere((e) => e.status == statusAtual)
        .clamp(0, etapasVisiveis.length - 1);

    final double alturaPasso = tamanhoCirculo + espacamentoVertical;
    final double alturaTotalLinha = alturaPasso * (etapasVisiveis.length - 1);
    final double alturaPreenchida = alturaPasso * indiceAtual;

    final bool isRecusado = statusAtual == StatusPedido.recusado;
    final Color corLinhaAtiva = isRecusado ? corRecusado : corAtiva;

    return Stack(
      children: [
        Positioned(
          left: (tamanhoCirculo / 2) - 1.5,
          top: tamanhoCirculo / 2,
          child: Container(
            width: 3,
            height: alturaTotalLinha,
            color: corInativa.withOpacity(0.5),
          ),
        ),
        Positioned(
          left: (tamanhoCirculo / 2) - 1.5,
          top: tamanhoCirculo / 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 3,
            height: alturaPreenchida,
            color: corLinhaAtiva,
          ),
        ),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(etapasVisiveis.length, (index) {
            final etapa = etapasVisiveis[index];
            final bool isUltimo = index == etapasVisiveis.length - 1;
            final bool isAlcancado = index <= indiceAtual;
            final bool isEtapaRecusada = etapa.status == StatusPedido.recusado;

            Color corItem;
            if (isEtapaRecusada) {
              corItem = corRecusado;
            } else if (isAlcancado) {
              corItem = corAtiva;
            } else {
              corItem = corInativa;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: isUltimo ? 0 : espacamentoVertical,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: tamanhoCirculo,
                    height: tamanhoCirculo,
                    decoration: BoxDecoration(
                      color: corItem,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      etapa.icone,
                      size: 22,
                      color: isEtapaRecusada
                          ? Colors.white
                          : (isAlcancado ? Colors.black87 : Colors.black45),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corItem,
                    ),
                    child: Text(etapa.titulo),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
