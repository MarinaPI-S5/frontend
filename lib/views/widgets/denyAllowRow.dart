import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/approvalButton.dart';
import 'package:frontend/views/widgets/rejectButton.dart';

class Denyallowrow extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Rejectbutton()),
        const SizedBox(width: 6),
        Expanded(child: Approvalbutton()),
      ],
    );
  }
}
