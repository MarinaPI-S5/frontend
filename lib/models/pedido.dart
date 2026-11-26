import 'package:frontend/models/embarcacao.dart';
import 'package:intl/intl.dart';

class ItemPedido {
  final String nome;
  final int quantidade;
  final double? valorUnitario;

  const ItemPedido({
    required this.nome,
    required this.quantidade,
    this.valorUnitario,
  });

  double? get subtotal =>
      valorUnitario != null ? valorUnitario! * quantidade : null;

  Map<String, dynamic> toJson() {
    return {
      'name': nome,
      'quantity': quantidade,
      if (valorUnitario != null) 'price': valorUnitario,
    };
  }

  String toXml(NumberFormat moeda) {
    final buffer = StringBuffer();
    buffer.writeln('    <produto>');
    buffer.writeln('      <nome>${Pedido.escapeXml(nome)}</nome>');
    buffer.writeln('      <quantidade>$quantidade</quantidade>');
    if (valorUnitario != null) {
      buffer.writeln(
        '      <valorUnitario>${Pedido.escapeXml(moeda.format(valorUnitario!))}</valorUnitario>',
      );
    }
    if (subtotal != null) {
      buffer.writeln(
        '      <subtotal>${Pedido.escapeXml(moeda.format(subtotal!))}</subtotal>',
      );
    }
    buffer.writeln('    </produto>');
    return buffer.toString();
  }
}

class Pedido extends Embarcacao {
  String? clientId;
  String responsavel;
  int qtdItens;
  double valor;
  DateTime horarioBrutoPedido;
  String status;
  String? motivo;
  List<ItemPedido> itens;

  Pedido({
    super.id,
    this.clientId,
    required super.embarcacao,
    required super.dono,
    required super.telefone,
    required this.responsavel,
    required this.qtdItens,
    required this.valor,
    required this.horarioBrutoPedido,
    this.status = 'analise',
    this.motivo,
    this.itens = const [],
  });

  String get preco {
    final formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return formatador.format(valor);
  }

  String get horarioPedido {
    final formatador = DateFormat('dd/MM/yyyy | HH:mm');

    return formatador.format(horarioBrutoPedido);
  }

  static String escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String toXml({
    String? nomeClienteOverride,
    String? statusOverride,
    String? motivoOverride,
  }) {
    final moeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final clienteFinal = _resolverNomePessoa([
      nomeClienteOverride,
      responsavel,
      dono,
    ]);
    final statusFinal = (statusOverride?.trim().isNotEmpty ?? false)
        ? statusOverride!.trim()
        : status.trim();
    final motivoFinal = (motivoOverride?.trim().isNotEmpty ?? false)
        ? motivoOverride!.trim()
        : (motivo?.trim() ?? '');

    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<pedido>');
    buffer.writeln('  <id>${escapeXml(id?.trim() ?? '')}</id>');
    buffer.writeln('  <cliente>${escapeXml(clienteFinal)}</cliente>');
    buffer.writeln(
      '  <embarcacao>${escapeXml(embarcacao.trim())}</embarcacao>',
    );
    buffer.writeln('  <dataHora>${escapeXml(horarioPedido.trim())}</dataHora>');
    buffer.writeln('  <status>${escapeXml(statusFinal)}</status>');

    if (motivoFinal.isNotEmpty) {
      buffer.writeln('  <motivo>${escapeXml(motivoFinal)}</motivo>');
    }

    buffer.writeln('  <produtos quantidadeTotal="$qtdItens">');
    for (final item in itens) {
      buffer.write(item.toXml(moeda));
    }
    buffer.writeln('  </produtos>');

    buffer.writeln('  <valorGasto>${escapeXml(preco)}</valorGasto>');
    buffer.writeln(
      '  <valorNumerico>${valor.toStringAsFixed(2)}</valorNumerico>',
    );
    buffer.writeln('</pedido>');
    return buffer.toString();
  }

  static bool _pareceEmail(String valor) {
    final v = valor.trim();
    return v.contains('@') && v.contains('.');
  }

  static bool _valorInvalido(String valor) {
    final v = valor.trim().toLowerCase();
    return v.isEmpty ||
        v == 'string' ||
        v == 'null' ||
        v == 'undefined' ||
        v.startsWith('cliente (');
  }

  static String _nomeAPartirDeEmail(String email) {
    final parteLocal = email.split('@').first.trim();
    if (parteLocal.isEmpty) return 'Cliente';
    final palavras = parteLocal
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .toList();
    return palavras.isEmpty ? 'Cliente' : palavras.join(' ');
  }

  static String _resolverNomePessoa(List<dynamic> candidatos) {
    for (final c in candidatos) {
      if (c == null) continue;
      final texto = c.toString().trim();
      if (!_valorInvalido(texto) && !_pareceEmail(texto)) {
        return texto;
      }
    }

    for (final c in candidatos) {
      if (c == null) continue;
      final texto = c.toString().trim();
      if (!_valorInvalido(texto) && _pareceEmail(texto)) {
        return _nomeAPartirDeEmail(texto);
      }
    }

    return 'Cliente';
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (clientId != null) 'client': clientId,
      'embarcacao': embarcacao,
      'boatName': embarcacao,
      'dono': dono,
      'telefone': telefone,
      'responsavel': responsavel,
      'responsibleEmail': responsavel,
      'qtdItens': qtdItens,
      'price': valor,
      'date': horarioBrutoPedido.toIso8601String(),
      'horarioPedido': horarioBrutoPedido.toIso8601String(),
      'status': status,
      if (motivo != null && motivo!.trim().isNotEmpty) 'reason': motivo!.trim(),
      if (itens.isNotEmpty) 'items': itens.map((e) => e.toJson()).toList(),
    };
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final boatRaw = json['boat'];
    final boatMap = boatRaw is Map<String, dynamic>
        ? boatRaw
        : (json['embarcacao'] is Map<String, dynamic>
              ? json['embarcacao'] as Map<String, dynamic>
              : <String, dynamic>{});

    final clientRaw = json['client'];
    final clientMap = clientRaw is Map<String, dynamic>
        ? clientRaw
        : (json['user'] is Map<String, dynamic>
              ? json['user'] as Map<String, dynamic>
              : <String, dynamic>{});

    final resolvedClientId = clientRaw is String
        ? clientRaw
        : (clientMap['_id'] ?? clientMap['id'] ?? json['clientId'])?.toString();

    final candidatoBarco =
        (json['boatName'] ??
                boatMap['name'] ??
                boatMap['embarcacao'] ??
                (json['embarcacao'] is String ? json['embarcacao'] : '') ??
                '')
            .toString()
            .trim();

    final regexBarcoId = RegExp(r'^Barco\s*\([^)]+\)$', caseSensitive: false);
    final nomeEmbarcacao =
        (candidatoBarco.isEmpty || regexBarcoId.hasMatch(candidatoBarco))
        ? 'Embarcação'
        : candidatoBarco;

    final nomeDono = _resolverNomePessoa([
      clientMap['name'],
      clientMap['nome'],
      json['clientName'],
      json['clienteNome'],
      boatMap['owner'],
      json['dono'],
      json['responsavel'],
      json['responsibleEmail'],
    ]);

    final telefoneContato =
        (clientMap['phone'] ?? clientMap['telefone'] ?? json['telefone'] ?? '')
            .toString();

    final nomeResponsavel = _resolverNomePessoa([
      clientMap['name'],
      clientMap['nome'],
      json['clientName'],
      json['clienteNome'],
      json['responsavel'],
      nomeDono,
      json['responsibleEmail'],
    ]);

    final itemsRaw = json['items'] ?? json['produtos'];
    final List<ItemPedido> listaItens = [];
    int totalItens = 0;

    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map<String, dynamic>) {
          final nomeItem =
              (item['name'] ?? item['nome'] ?? item['item'] ?? 'Produto')
                  .toString()
                  .trim();
          final qtyRaw = item['quantity'] ?? item['quantidade'] ?? 1;
          final qty = qtyRaw is int
              ? qtyRaw
              : int.tryParse(qtyRaw.toString()) ?? 1;

          final unitRaw = item['price'] ?? item['valor'] ?? item['unitPrice'];
          final unitVal = unitRaw is num
              ? unitRaw.toDouble()
              : (unitRaw != null
                    ? double.tryParse(unitRaw.toString().replaceAll(',', '.'))
                    : null);

          totalItens += qty;
          listaItens.add(
            ItemPedido(
              nome: nomeItem.isEmpty ? 'Produto' : nomeItem,
              quantidade: qty,
              valorUnitario: unitVal,
            ),
          );
        } else if (item != null) {
          totalItens += 1;
          listaItens.add(
            ItemPedido(nome: item.toString().trim(), quantidade: 1),
          );
        }
      }
    } else {
      final rawQtd = json['qtdItens'] ?? json['itemsCount'];
      totalItens = int.tryParse(rawQtd?.toString() ?? '') ?? 0;
    }

    final rawPrice = json['price'] ?? json['valor'] ?? 0;
    final valorNumerico = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString().replaceAll(',', '.')) ?? 0.0;

    final rawHorario =
        json['horarioPedido'] ??
        json['horarioBrutoPedido'] ??
        json['createdAt'] ??
        json['date'];
    final parsedDate =
        DateTime.tryParse(rawHorario?.toString() ?? '')?.toLocal() ??
        DateTime.now();

    final rawStatus = (json['status'] ?? 'analise').toString();

    final rawMotivo =
        (json['reason'] ??
                json['motivo'] ??
                json['denialReason'] ??
                json['observation'] ??
                '')
            .toString()
            .trim();

    return Pedido(
      id: (json['_id'] ?? json['id'])?.toString(),
      clientId: resolvedClientId,
      embarcacao: nomeEmbarcacao,
      dono: nomeDono,
      telefone: telefoneContato,
      responsavel: nomeResponsavel,
      qtdItens: totalItens,
      valor: valorNumerico,
      horarioBrutoPedido: parsedDate,
      status: rawStatus,
      motivo: rawMotivo.isEmpty ? null : rawMotivo,
      itens: listaItens,
    );
  }
}
