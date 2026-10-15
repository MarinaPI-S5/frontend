import 'package:flutter/material.dart';
import 'package:frontend/models/pedido.dart';

class DetalhesPedidoScreen extends StatefulWidget {
  final Pedido pedido;

  const DetalhesPedidoScreen({
    super.key,
    required this.pedido,
  });

  @override
  State<DetalhesPedidoScreen> createState() =>
      _DetalhesPedidoScreenState();
}

class _DetalhesPedidoScreenState
    extends State<DetalhesPedidoScreen> {
  final TextEditingController motivoController =
      TextEditingController();

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      backgroundColor: Colors.white,

      
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(108),
  child: Container(
    width: double.infinity,
    color: const Color(0xFF1D1D1D),
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 108,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Text(
                'Pedido - ${widget.pedido.embarcacao}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 28,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),


      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 13),
            width: 13,
            height: 2,
            color: const Color(0xFFFF45B8),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                13,
                14,
                13,
                20,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalhes do pedido',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDADA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pendente',
                            style: TextStyle(
                              color: Color(0xFFE53950),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _linhaInformacao(
                      'Embarcação',
                      pedido.embarcacao,
                    ),

                    const SizedBox(height: 13),

                    _linhaInformacao(
                      'Dono',
                      pedido.dono,
                    ),

                    const SizedBox(height: 13),

                    _linhaInformacao(
                      'Data',
                      pedido.horarioPedido.split(' | ').first,
                    ),

                    const SizedBox(height: 13),

                    _linhaInformacao(
                      'Responsável',
                      pedido.responsavel,
                    ),

                    const SizedBox(height: 13),

                    _linhaInformacao(
                      'Quantidade de itens',
                      pedido.qtdItens.toString(),
                    ),

                    const SizedBox(height: 13),

                    _linhaInformacao(
                      'Valor',
                      pedido.preco,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Descreva o motivo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    TextField(
                      controller: motivoController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'Digite aqui...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        contentPadding:
                            const EdgeInsets.all(9),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFCCCCCC),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: OutlinedButton(
                              onPressed: () {
                                mostrarMensagem(
                                  'Geração de XML ainda não implementada.',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF1683FF),
                                side: const BorderSide(
                                  color: Color(0xFF1683FF),
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Gerar XML',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: () {
                                final motivo =
                                    motivoController.text.trim();

                                if (motivo.isEmpty) {
                                  mostrarMensagem(
                                    'Descreva o motivo antes de enviar.',
                                  );
                                  return;
                                }

                                mostrarMensagem(
                                  'Motivo preenchido. '
                                  'Integração de envio pendente.',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF28A745),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Enviar',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(7, 0, 7, 10),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D25),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _itemNavegacao(Icons.home_outlined, 'Home'),
            _itemNavegacao(Icons.person_outline, 'Clientes'),
            _itemNavegacao(Icons.sailing_outlined, 'Embarcações'),
            _itemNavegacao(Icons.settings_outlined, 'Configuração'),
          ],
        ),
      ),
    );
  }

  Widget _linhaInformacao(String titulo, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _itemNavegacao(IconData icone, String titulo) {
    return InkWell(
      onTap: () {
        mostrarMensagem(
          'Navegação para $titulo ainda não implementada.',
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 62,
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 17,
              color: Colors.white70,
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}