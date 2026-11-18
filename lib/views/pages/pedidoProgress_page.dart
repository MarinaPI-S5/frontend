import 'package:flutter/material.dart';
import 'package:frontend/models/etapaStatus.dart';
import 'package:frontend/models/pedido.dart';
import 'package:frontend/views/widgets/slideButton.dart';
import 'package:frontend/views/widgets/barraProgressoVertical.dart';
import 'package:frontend/views/widgets/statusBadge.dart';

class PedidoProgressPage extends StatefulWidget {
  final Pedido pedido;

  const PedidoProgressPage({super.key, required this.pedido});

  @override
  State<PedidoProgressPage> createState() => _PedidoProgressPageState();
}

class _PedidoProgressPageState extends State<PedidoProgressPage> {
  StatusPedido _statusAtual = StatusPedido.emAnalise;

  final List<StatusPedido> _fluxoNormal = [
    StatusPedido.emAnalise,
    StatusPedido.aprovado,
    StatusPedido.emEspera,
    StatusPedido.emPreparo,
    StatusPedido.pronto,
    StatusPedido.navegando,
    StatusPedido.retornando,
    StatusPedido.encerrado,
  ];

  void _avancarFluxo() {
    if (_statusAtual == StatusPedido.recusado ||
        _statusAtual == StatusPedido.encerrado) {
      setState(() => _statusAtual = StatusPedido.emAnalise);
      return;
    }

    final int idx = _fluxoNormal.indexOf(_statusAtual);

    if (idx < _fluxoNormal.length - 1) {
      setState(() => _statusAtual = _fluxoNormal[idx + 1]);
    }
  }

  void _iniciarPasseio() {
    setState(() {
      _statusAtual = StatusPedido.navegando;
    });
  }

  void _retornarPasseio() {
    setState(() {
      _statusAtual = StatusPedido.retornando;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Status do Pedido'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 850),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Text(
                    widget.pedido.embarcacao,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Positioned(
                    right: 30,
                    child: StatusBadge(
                      concluido:
                          _statusAtual == StatusPedido.encerrado ||
                          _statusAtual == StatusPedido.recusado,
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimelineStatusVertical(statusAtual: _statusAtual),
                          const SizedBox(height: 40),
                          if (_statusAtual == StatusPedido.pronto)
                            SlideButton(
                              key: const ValueKey('iniciar'),
                              text: 'Deslize para iniciar passeio',
                              color: Colors.green,
                              icon: Icons.directions_boat,
                              onSubmit: _iniciarPasseio,
                            ),

                          if (_statusAtual == StatusPedido.navegando)
                            SlideButton(
                              key: const ValueKey('retornar'),
                              text: 'Deslize para retornar',
                              color: Colors.orange,
                              backgroundColor: const Color(0xFFFFF0DC),
                              icon: Icons.keyboard_return,
                              onSubmit: _retornarPasseio,
                            ),
                          const SizedBox(height: 40),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _avancarFluxo,
                                child: Text(
                                  _statusAtual == StatusPedido.recusado ||
                                          _statusAtual == StatusPedido.encerrado
                                      ? 'Reiniciar Análise'
                                      : 'Avançar Etapa',
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _statusAtual = StatusPedido.recusado,
                                  );
                                },
                                child: const Text('Simular Recusa'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
