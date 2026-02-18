import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'db_helper.dart'; // Para usar el modelo Task si es necesario

class StorageService {
  // A) Secure Storage (Token)
  final _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // B) SharedPreferences (Configuración)
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_dark_mode') ?? false; // Por defecto claro
  }

  Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? "Usuario";
  }

  // C) Archivos Locales (Exportación)
  Future<String> exportTasksToFile(List<Task> tasks) async {
    try {
      // 1. Convertir tareas a JSON
      List<Map<String, dynamic>> jsonList = tasks
          .map((e) => e.toMap())
          .toList();
      String jsonString = jsonEncode(jsonList);

      // 2. Obtener directorio
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks_backup.json');

      // 3. Escribir contenido
      await file.writeAsString(jsonString);

      return file.path; // Retornamos la ruta para mostrarla al usuario
    } catch (e) {
      throw Exception("Error al exportar: $e");
    }
  }
}
