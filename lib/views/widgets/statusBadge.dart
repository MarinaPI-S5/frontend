import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool concluido;

  const StatusBadge({super.key, required this.concluido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: concluido ? const Color(0xFFD7F5E2) : const Color(0xFFFFF1E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        concluido ? 'Concluído' : 'Em andamento',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: concluido ? const Color(0xFF20C45A) : const Color(0xFFFF8A26),
        ),
      ),
    );
  }
}
