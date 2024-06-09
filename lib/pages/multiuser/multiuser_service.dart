import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trading.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create a table to store user accounts
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      idno TEXT NOT NULL
    )
    ''');
  }

  Future<void> createUserTable(String userName) async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${userName}_stocks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      buyPrice REAL,
      buyDate TEXT,
      buyAmount REAL
    )
    ''');
  }

  Future<void> insertStock(String userName, Map<String, dynamic> stock) async {
    final db = await instance.database;

    await db.insert(
      '${userName}_stocks',
      stock,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getStocks(String userName) async {
    final db = await instance.database;

    return await db.query('${userName}_stocks');
  }

  Future<void> addUser(String userName, String userId) async {
    final db = await instance.database;

    await db.insert(
      'users',
      {'name': userName, 'idno': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create user-specific table
    await createUserTable(userName);
  }

  Future<void> deleteUser(String userName) async {
    final db = await instance.database;
    await db.delete('users', where: 'name=?', whereArgs: [userName]);
    await db.rawQuery('DROP TABLE ${userName}_stocks');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;

    return await db.query('users');
  }
}
