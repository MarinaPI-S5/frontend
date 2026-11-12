import 'package:flutter/material.dart';

class Approvalbutton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Ação de permitir
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF28A745),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(0, 60),
      ),
      child: const Text(
        'Permitir',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
