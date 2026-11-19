import 'dart:typed_data';

class DocumentoEmbarcacao {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int sizeInBytes;

  const DocumentoEmbarcacao({
    required this.name,
    this.path,
    this.bytes,
    required this.sizeInBytes,
  });

  String get formattedSize {
    final kb = sizeInBytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
