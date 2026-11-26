import 'package:frontend/models/pedido.dart';
import 'package:intl/intl.dart';

class XmlPedidoHelper {
  static final _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String gerarXmlPedido({
    required Pedido pedido,
    required String nomeCliente,
    required String statusTexto,
    String motivo = '',
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<pedido>');
    buffer.writeln('  <id>${_escapeXml(pedido.id?.trim() ?? '')}</id>');
    buffer.writeln('  <cliente>${_escapeXml(nomeCliente.trim())}</cliente>');
    buffer.writeln(
      '  <embarcacao>${_escapeXml(pedido.embarcacao.trim())}</embarcacao>',
    );
    buffer.writeln(
      '  <dataHora>${_escapeXml(pedido.horarioPedido.trim())}</dataHora>',
    );
    buffer.writeln('  <status>${_escapeXml(statusTexto.trim())}</status>');

    if (motivo.trim().isNotEmpty) {
      buffer.writeln('  <motivo>${_escapeXml(motivo.trim())}</motivo>');
    }

    buffer.writeln('  <produtos quantidadeTotal="${pedido.qtdItens}">');
    for (final item in pedido.itens) {
      buffer.writeln('    <produto>');
      buffer.writeln('      <nome>${_escapeXml(item.nome)}</nome>');
      buffer.writeln('      <quantidade>${item.quantidade}</quantidade>');
      if (item.valorUnitario != null) {
        buffer.writeln(
          '      <valorUnitario>${_escapeXml(_moeda.format(item.valorUnitario!))}</valorUnitario>',
        );
      }
      if (item.subtotal != null) {
        buffer.writeln(
          '      <subtotal>${_escapeXml(_moeda.format(item.subtotal!))}</subtotal>',
        );
      }
      buffer.writeln('    </produto>');
    }
    buffer.writeln('  </produtos>');

    buffer.writeln('  <valorTotal>${_escapeXml(pedido.preco)}</valorTotal>');
    buffer.writeln('</pedido>');
    return buffer.toString();
  }
}
