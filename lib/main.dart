import 'package:flutter/material.dart';
import 'package:frontend/views/pages/cadastroCliente_page.dart';
import 'package:frontend/views/pages/cadastroEmbarcacao_page.dart';
import 'package:frontend/views/pages/home_page.dart';
import 'package:frontend/views/widgets/headerCard.dart';
import 'package:frontend/views/widgets/navbarCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Bem vindo,\nCliente !',
    'Cadastro de Clientes',
    'Cadastro de Embarcações',
    'Configurações do Sistema',
  ];

  final List<Widget> _pages = const [
    HomeClientePage(),
    CadastroclientePage(),
    CadastroembarcacaoPage(),
    Center(child: Text('Configurações')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Marina",
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomHeader(
                title: _titles[_selectedIndex],
                onBackPressed: () {},
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        ),

        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
