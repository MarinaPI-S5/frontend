import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/cadastroCliente_viewmodel.dart';

class CadastroclientePage extends StatefulWidget {
  const CadastroclientePage({super.key});

  @override
  State<CadastroclientePage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<CadastroclientePage> {
  final _viewModel = CadastroclienteViewmodel();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rgController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rgController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Criar conta'),
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
                  label: 'Nome completo',
                  icon: Icons.person_outline,
                  validator: _viewModel.validateName,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'E-mail',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: _viewModel.validateEmail,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'RG',
                  icon: Icons.document_scanner_sharp,
                  keyboardType: TextInputType.phone,
                  validator: _viewModel.validateRg,
                  controller: _rgController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'CPF',
                  icon: Icons.document_scanner_sharp,
                  keyboardType: TextInputType.phone,
                  validator: _viewModel.validateCpf,
                  controller: _cpfController,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  validator: _viewModel.validatePassword,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Confirmar senha',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  controller: _confirmPasswordController,
                  validator: (value) => _viewModel.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 8),

                _buildTermsCheckbox(),
                const SizedBox(height: 16),

                _buildSubmitButton(),
                const SizedBox(height: 8),

                _buildLoginLink(context),
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
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        final isValid = _formKey.currentState!.validate();
        print('formulário válido? $isValid');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Criar conta',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      value: _acceptedTerms,
      onChanged: (value) {
        setState(() {
          _acceptedTerms = value ?? false;
        });
      },
      activeColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text(
        'Li e aceito os termos de uso e a política de privacidade',
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      child: const Text('Já tenho uma conta'),
    );
  }
}
