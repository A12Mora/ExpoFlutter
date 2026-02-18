import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Esta es la clase que contiene la lógica y el diseño (Estado)
class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final StorageService _storageService = StorageService();

  // FUNCIÓN DE LOGIN:
  // Es 'async' (asíncrona) porque guardar datos toma tiempo y debemos esperar

  void _login() async {
    String user = _userController.text;
    String pass = _passController.text;

    // Validación simulada
    if (user.isNotEmpty && pass == "1234") {
      // 1. Generar token simulado
      String token = "user_token_${DateTime.now().millisecondsSinceEpoch}";

      // 2. Guardar token y usuario
      await _storageService.saveToken(token);
      await _storageService.saveUsername(user);

      // 3. Navegar a Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales inválidas (Use pass: 1234)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Usuario"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Contraseña (1234)"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Entrar")),
          ],
        ),
      ),
    );
  }
}
