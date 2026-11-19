import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

                const Text(
                  'Pedido',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Lista de itens dinâmicos baseados no ViewModel
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _viewModel.itensDisponiveis.length,
                  itemBuilder: (context, index) {
                    final item = _viewModel.itensDisponiveis[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Checkbox e Nome do Produto
                          Row(
                            children: [
                              Checkbox(
                                value: item.selecionado,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _viewModel.toggleItemSelecao(item, value);
                                  });
                                },
                              ),
                              Text(
                                item.nome,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          // Controles de Quantidade (+ Quantidade -)
                          Row(
                            children: [
                              InkWell(
                                onTap: item.selecionado
                                    ? () {
                                        setState(() {
                                          _viewModel.decrementarQuantidade(
                                            item,
                                          );
                                        });
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: item.selecionado
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.selecionado
                                    ? '${item.quantidade}'
                                    : 'Quantidade',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item.selecionado
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: item.selecionado
                                    ? () {
                                        setState(() {
                                          _viewModel.incrementarQuantidade(
                                            item,
                                          );
                                        });
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: item.selecionado
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Valor Total Dinâmico
                Text(
                  "VALOR TOTAL: R\$ ${_viewModel.valorTotal.toStringAsFixed(2).replaceAll('.', ',')}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    final isValid = _formKey.currentState!.validate();
                    print('formulário válido? $isValid');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Concluir Agendamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
