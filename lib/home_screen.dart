import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'storage_service.dart';
import 'login_screen.dart';
import 'main.dart';

// Importante: Para abrir el archivo automáticamente se necesita el paquete open_file_plus
//import 'package:open_file_plus/open_file_plus.dart';

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

    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // --- LÓGICA DE TAREAS ---
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

  // --- CONFIGURACIÓN Y EXPORTACIÓN ---
  void _toggleTheme(bool value) async {
    await _storageService.saveTheme(value);
    setState(() => _isDarkMode = value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  void _exportTasks() async {
    try {
      String path = await _storageService.exportTasksToFile(_tasks);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportado en: $path'),
            action: SnackBarAction(
              label: "ABRIR",
              onPressed: () {
                //OpenFile.open(path);
              },
            ),
          ),
        );
        // Lógica para abrir automáticamente:
        //await OpenFile.open(path);
      }
    } catch (e) {
      debugPrint("Error exportando: $e");
    }
  }

  void _logout() async {
    await _storageService.deleteToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // --- UI: DIALOGO CON DESCRIPCIÓN ADAPTABLE ---
  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nueva Tarea"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descController,
                // SOLUCIÓN AL PROBLEMA DE DESCRIPCIÓN:
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  hintText: "Escribe aquí los detalles...",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addTask(titleController.text, descController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("GUARDAR"),
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: "Exportar Tareas",
            onPressed: _exportTasks,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Switch de Tema estético
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: SwitchListTile(
                secondary: Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text("Modo Oscuro"),
                value: _isDarkMode,
                onChanged: _toggleTheme,
              ),
            ),
          ),
          const Divider(),
          // Lista de Tareas
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text("No hay tareas pendientes"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.completed,
                            shape: const CircleBorder(),
                            onChanged: (_) => _toggleTask(task),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(task.description),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteTask(task.id!),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Añadir Tarea"),
      ),
    );
  }
}
