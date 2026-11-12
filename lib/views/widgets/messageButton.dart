import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Messagebutton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Abrir o Whatsapp com o telefone adicionado
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF28A745),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(0, 60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),

          const SizedBox(width: 16),

          const Text(
            'Enviar mensagem',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
