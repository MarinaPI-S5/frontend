import 'package:flutter/material.dart';

enum StatusPedido {
  emAnalise,
  aprovado,
  emEspera,
  emPreparo,
  pronto,
  navegando,
  retornando,
  encerrado,
  recusado,
}

class EtapaStatus {
  final StatusPedido status;
  final String titulo;
  final IconData icone;

  const EtapaStatus({
    required this.status,
    required this.titulo,
    required this.icone,
  });
}
