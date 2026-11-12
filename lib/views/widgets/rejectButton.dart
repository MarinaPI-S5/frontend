import 'package:flutter/material.dart';

class Rejectbutton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // Ação de negar
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF3333),
        side: const BorderSide(color: Color(0xFFFF3333), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(0, 60),
      ),
      child: const Text(
        'Negar',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
