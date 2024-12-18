import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_with_sqflite/models/task.dart';

class DatabaseService {
  static Database? db;
  static DatabaseService instance = DatabaseService.constructor();

  final String taskTableName = "tasks";
  final String taskColumnId = "id";
  final String taskContentName = "content";
  final String taskStatus = "status";
  DatabaseService.constructor();

  Future<Database> get database async {
    if (db != null) {
      return db!;
    } else {
      db = await getDatabase();
      return db!;
    }
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      db.execute('''
CREATE TABLE $taskTableName (
  $taskColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
  $taskContentName TEXT NOT NULL,
  $taskStatus INTEGER NOT NULL
)
''');
    });
    return database;
  }

  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(taskTableName, {taskContentName: content, taskStatus: 0});
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(taskTableName);
    return data
        .map((e) => Task(
              id: e["id"] as int,
              content: e["content"] as String,
              status: e["status"] as int,
            ))
        .toList();
  }

  Future<void> updateTask(int id, String updatedContent) async {
    final db = await database;
    await db.update(
      taskTableName,
      {taskContentName: updatedContent},
      where: '$taskColumnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      taskTableName,
      where: '$taskColumnId = ?',
      whereArgs: [id],
    );
  }
}
