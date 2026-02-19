import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'storage_service.dart';

// Notificador global para cambiar el tema desde cualquier parte
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // 1. Siempre primero
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final StorageService storage = StorageService();
    // Agregamos un try-catch por si el storage falla al iniciar
    String? token = await storage.getToken();
    bool isDark = await storage.getTheme();

    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    runApp(
      MyApp(
        initialRoute: token != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  } catch (e) {
    // Si algo falla, arrancamos la app igual con el Login para evitar el pantallazo negro
    runApp(const MyApp(initialRoute: LoginScreen()));
  }
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder escucha cambios en themeNotifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Organizador Offline',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode, // Aplica el modo actual
          home: initialRoute,
        );
      },
    );
  }
}
