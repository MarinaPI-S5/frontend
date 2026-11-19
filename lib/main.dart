import 'package:flutter/material.dart';
import 'package:frontend/data/repositores/cliente_repository.dart';
import 'package:frontend/views/pages/homeLogin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ClienteRepository().restoreSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marina',
      home: const LoginPage(),
    );
  }
}
