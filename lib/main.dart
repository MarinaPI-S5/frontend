import 'package:flutter/material.dart';
import 'package:frontend/views/filaPedidos.dart';

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

  // Declarado fora do build para melhor performance
  final List<Widget> _pages = const [
    Filapedidos(),
    Center(child: Text('Tela de Clientes')),
    Center(child: Text('Embarcações')),
    Center(child: Text('Configurações')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Marina",
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30), // Correção aqui
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Colors.white);
                    }
                    return const IconThemeData(color: Colors.grey);
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      );
                    }
                    return const TextStyle(color: Colors.grey, fontSize: 10);
                  }),
                  indicatorColor: Colors.blueAccent.withValues(alpha: 0.3),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.black,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      label: 'Início',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outlined),
                      label: 'Clientes',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.sailing_outlined),
                      label: 'Embarcações',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: 'Configurações',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
