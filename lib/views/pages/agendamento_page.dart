import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para List<TextInputFormatter>
import 'package:frontend/viewmodels/agendamento_viewmodel.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _viewModel = AgendamentoViewModel();

  final _proprietarioController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _embarcacaoController = TextEditingController();
  final _dataController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _proprietarioController.dispose();
    _responsavelController.dispose();
    _embarcacaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Agendar serviço'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                _buildField(
                  label: 'Proprietario',
                  icon: Icons.person,
                  validator: _viewModel.validateProprietario,
                  controller: _proprietarioController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Responsável',
                  icon: Icons.person,
                  validator: _viewModel.validateResponsavel,
                  controller: _responsavelController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Nome da Embarcação',
                  icon: Icons.directions_boat,
                  validator: _viewModel.validateEmbarcacao,
                  controller: _embarcacaoController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Data do agendamento',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_viewModel.dateMaskFormatter],
                  validator: _viewModel.validateData,
                  controller: _dataController,
                  hintText: 'DD/MM/AAAA',
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                  child: const Text('Salvar Agendamento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
