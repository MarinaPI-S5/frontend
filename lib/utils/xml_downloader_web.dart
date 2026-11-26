import 'dart:convert';
import 'dart:html' as html;

Future<String> salvarXml(String nomeArquivo, String conteudoXml) async {
  final bytes = utf8.encode(conteudoXml);
  final blob = html.Blob([bytes], 'application/xml;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', nomeArquivo)
    ..click();

  html.Url.revokeObjectUrl(url);
  return 'Download iniciado: $nomeArquivo';
}
