import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> salvarXml(String nomeArquivo, String conteudoXml) async {
  final dir = Platform.isAndroid || Platform.isIOS
      ? await getApplicationDocumentsDirectory()
      : (await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory());

  final caminho = '${dir.path}/$nomeArquivo';
  await File(caminho).writeAsString(conteudoXml, encoding: utf8);
  return 'XML salvo em: $caminho';
}
