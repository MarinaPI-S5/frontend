import 'package:flutter/foundation.dart';
import 'package:frontend/data/network/embarcacao_request.dart';
import 'package:frontend/data/repositores/embarcacao_repository.dart';
import 'package:frontend/data/session/session_store.dart';
import 'package:frontend/models/documento_embarcacao.dart';

class CadastroEmbarcacaoViewModel {
  final EmbarcacaoRepository _repository;

  CadastroEmbarcacaoViewModel({EmbarcacaoRepository? repository})
    : _repository = repository ?? EmbarcacaoRepository();

  static const int maxFileSizeBytes = 25 * 1024 * 1024;

  final ValueNotifier<DocumentoEmbarcacao?> boatdocNotifier =
      ValueNotifier<DocumentoEmbarcacao?>(null);

  final ValueNotifier<DocumentoEmbarcacao?> insuranceNotifier =
      ValueNotifier<DocumentoEmbarcacao?>(null);

  final ValueNotifier<bool> isUploadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);

  Future<void> selecionarBoatdoc() async {
    await _selecionarArquivo(onSelected: (doc) => boatdocNotifier.value = doc);
  }

  void removerBoatdoc() {
    errorNotifier.value = null;
    boatdocNotifier.value = null;
  }

  Future<void> selecionarInsurance() async {
    await _selecionarArquivo(
      onSelected: (doc) => insuranceNotifier.value = doc,
    );
  }

  void removerInsurance() {
    errorNotifier.value = null;
    insuranceNotifier.value = null;
  }

  Future<void> _selecionarArquivo({
    required ValueChanged<DocumentoEmbarcacao> onSelected,
  }) async {
    errorNotifier.value = null;

    try {
      final doc = await _repository.pickDocument();
      if (doc == null) return;

      if (doc.sizeInBytes > maxFileSizeBytes) {
        errorNotifier.value = 'O arquivo deve ter no máximo 25 MB.';
        return;
      }

      onSelected(doc);
    } catch (e) {
      errorNotifier.value = e.toString().replaceFirst('Exception: ', '').trim();
    }
  }

  String? _obterClienteIdLogado() {
    final dynamic session = SessionStore.notifier.value;
    if (session == null) return null;

    try {
      final userId = session.user?.id ?? session.clienteId ?? session.id;
      final value = userId?.toString().trim();
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<bool> cadastrarEmbarcacao({required String name}) async {
    errorNotifier.value = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      errorNotifier.value = 'Informe o nome da embarcação.';
      return false;
    }

    final clienteId = _obterClienteIdLogado();
    if (clienteId == null) {
      errorNotifier.value = 'Sessão expirada ou cliente não autenticado.';
      return false;
    }

    final boatdoc = boatdocNotifier.value;
    final insurance = insuranceNotifier.value;

    if (boatdoc == null && insurance == null) {
      errorNotifier.value =
          'Anexe pelo menos um documento (TIE ou Seguro obrigatório DEPEM).';
      return false;
    }

    isUploadingNotifier.value = true;

    try {
      final request = EmbarcacaoRequest(
        clienteId: clienteId,
        name: trimmedName,
        boatdoc: boatdoc,
        insurance: insurance,
      );

      await _repository.criarEmbarcacao(request);
      return true;
    } catch (e) {
      errorNotifier.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      isUploadingNotifier.value = false;
    }
  }

  void dispose() {
    boatdocNotifier.dispose();
    insuranceNotifier.dispose();
    isUploadingNotifier.dispose();
    errorNotifier.dispose();
  }
}
