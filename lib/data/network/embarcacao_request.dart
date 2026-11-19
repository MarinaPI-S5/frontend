import 'package:frontend/models/documento_embarcacao.dart';

class EmbarcacaoRequest {
  final String clienteId;
  final String name;
  final DocumentoEmbarcacao? boatdoc;
  final DocumentoEmbarcacao? insurance;

  const EmbarcacaoRequest({
    required this.clienteId,
    required this.name,
    this.boatdoc,
    this.insurance,
  });

  EmbarcacaoRequest copyWith({
    String? clienteId,
    String? name,
    DocumentoEmbarcacao? boatdoc,
    bool clearBoatdoc = false,
    DocumentoEmbarcacao? insurance,
    bool clearInsurance = false,
  }) {
    return EmbarcacaoRequest(
      clienteId: clienteId ?? this.clienteId,
      name: name ?? this.name,
      boatdoc: clearBoatdoc ? null : (boatdoc ?? this.boatdoc),
      insurance: clearInsurance ? null : (insurance ?? this.insurance),
    );
  }
}
