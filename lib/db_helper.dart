import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;

  // Constructor. Exige título y descripción. Por defecto, 'completed' es falso.
  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });

  // Convierte un objeto Task en un Map (diccionario) para guardarlo en la BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // SQLite no tiene booleanos. Guardamos 1 si es true, o 0 si es false.
      'completed': completed ? 1 : 0,
    };
  }

  // Crea un objeto Task a partir de un Map obtenido de la BD
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      completed: map['completed'] == 1,
    );
  }
}

// Getter para obtener la base de datos. Si no existe, la inicializa.
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'organizador.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, completed INTEGER)",
        );
      },
    );
  }

  // --- OPERACIONES CRUD (Crear, Leer, Actualizar, Borrar) ---
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
