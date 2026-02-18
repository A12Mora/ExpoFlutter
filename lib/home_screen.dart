import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'storage_service.dart';
import 'login_screen.dart';
import 'main.dart'; // Importamos para acceder al ValueNotifier del tema

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  final StorageService _storageService = StorageService();

  List<Task> _tasks = [];
  String _username = "";
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _dbHelper.getTasks();
    final user = await _storageService.getUsername();
    final isDark = await _storageService.getTheme();

    setState(() {
      _tasks = tasks;
      _username = user;
      _isDarkMode = isDark;
    });

    // Actualizar el tema global
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Lógica de Tareas (SQLite)
  Future<void> _addTask(String title, String desc) async {
    await _dbHelper.insertTask(Task(title: title, description: desc));
    _loadData();
  }

  Future<void> _toggleTask(Task task) async {
    await _dbHelper.updateTask(
      Task(
        id: task.id,
        title: task.title,
        description: task.description,
        completed: !task.completed,
      ),
    );
    _loadData();
  }

  Future<void> _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _loadData();
  }

  // Lógica de Configuración (Prefs)
  void _toggleTheme(bool value) async {
    await _storageService.saveTheme(value);
    setState(() {
      _isDarkMode = value;
    });
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  // Lógica de Exportación (Archivos)
  void _exportTasks() async {
    try {
      String path = await _storageService.exportTasksToFile(_tasks);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tareas exportadas en: $path')));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Lógica de Logout
  void _logout() async {
    await _storageService.deleteToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // UI Dialog para agregar tarea
  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva Tarea"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Título"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: "Descripción"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addTask(titleController.text, descController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hola, $_username"),
        actions: [
          IconButton(icon: const Icon(Icons.save_alt), onPressed: _exportTasks),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Sección Configuración
          SwitchListTile(
            title: const Text("Modo Oscuro"),
            value: _isDarkMode,
            onChanged: _toggleTheme,
          ),
          const Divider(),
          // Lista de Tareas
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (_) => _toggleTask(task),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(task.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(task.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
