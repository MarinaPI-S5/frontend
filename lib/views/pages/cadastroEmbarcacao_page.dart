import 'package:flutter/material.dart';
import 'package:frontend/models/documento_embarcacao.dart';
import 'package:frontend/viewmodels/cadastroEmbarcacao_viewmodel.dart';

class CadastroembarcacaoPage extends StatefulWidget {
  const CadastroembarcacaoPage({super.key});

  @override
  State<CadastroembarcacaoPage> createState() => _CadastroembarcacaoPageState();
}

class _CadastroembarcacaoPageState extends State<CadastroembarcacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _viewModel = CadastroEmbarcacaoViewModel();

  @override
  void dispose() {
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Cadastrar Embarcação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome da embarcação',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o nome da embarcação';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          ValueListenableBuilder<DocumentoEmbarcacao?>(
                            valueListenable: _viewModel.boatdocNotifier,
                            builder: (context, doc, child) {
                              return _buildDocumentCard(
                                title: 'Documento TIE',
                                documento: doc,
                                onTap: _viewModel.selecionarBoatdoc,
                                onRemove: _viewModel.removerBoatdoc,
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          ValueListenableBuilder<DocumentoEmbarcacao?>(
                            valueListenable: _viewModel.insuranceNotifier,
                            builder: (context, doc, child) {
                              return _buildDocumentCard(
                                title: 'Seguro obrigatório DEPEM',
                                documento: doc,
                                onTap: _viewModel.selecionarInsurance,
                                onRemove: _viewModel.removerInsurance,
                              );
                            },
                          ),

                          ValueListenableBuilder<String?>(
                            valueListenable: _viewModel.errorNotifier,
                            builder: (context, error, child) {
                              if (error == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required DocumentoEmbarcacao? documento,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasFile = documento != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: hasFile ? Colors.green : Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                hasFile ? Icons.description : Icons.attach_file,
                color: hasFile ? Colors.green : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFile
                          ? '${documento.name} (${documento.formattedSize})'
                          : 'Toque para anexar arquivo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Remover arquivo',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isUploadingNotifier,
      builder: (context, isLoading, child) {
        return ElevatedButton(
          onPressed: isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Gerar Contrato',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.cadastrarEmbarcacao(
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Embarcação cadastrada com sucesso!')),
      );
      Navigator.pop(context);
    } else if (_viewModel.errorNotifier.value != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.errorNotifier.value!)));
    }
  }
}
