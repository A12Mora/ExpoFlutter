import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'storage_service.dart';

// Notificador global para cambiar el tema desde cualquier parte
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verificamos token y tema guardado antes de arrancar
  final StorageService storage = StorageService();
  String? token = await storage.getToken();
  bool isDark = await storage.getTheme();

  // Establecemos el tema inicial
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(
    MyApp(
      initialRoute: token != null ? const HomeScreen() : const LoginScreen(),
    ),
  );
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
