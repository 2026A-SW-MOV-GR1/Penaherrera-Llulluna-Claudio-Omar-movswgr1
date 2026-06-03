import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/rest_controller.dart';
import 'controllers/secrets_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestController()),
        ChangeNotifierProvider(create: (_) => SecretsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Red y Seguridad',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

