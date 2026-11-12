import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AgendamentoViewModel extends ChangeNotifier {
  final MaskTextInputFormatter dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  String? validateProprietario(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe o nome do Proprietario';
    if (name.length < 3) return 'O nome deve ter pelo menos 3 letras';
    return null;
  }

  String? validateResponsavel(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe o nome do Responsavel';
    if (name.length < 3) return 'O nome deve ter pelo menos 3 letras';
    return null;
  }

  String? validateEmbarcacao(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe o nome da Embarcação';
    if (name.length < 3) return 'O nome deve ter pelo menos 3 letras';
    return null;
  }

  String? validateData(String? value) {
    final data = value?.trim() ?? '';

    if (data.isEmpty) {
      return 'Informe a data';
    }

    if (data.length < 10) {
      return 'Digite uma data completa no formato DD/MM/AAAA';
    }

    if (!_isDataValida(data)) {
      return 'Data inválida';
    }

    return null;
  }

  bool _isDataValida(String dataStr) {
    try {
      final partes = dataStr.split('/');
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      final data = DateTime(ano, mes, dia);
      return data.year == ano && data.month == mes && data.day == dia;
    } catch (_) {
      return false;
    }
  }
}
