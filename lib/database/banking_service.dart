// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class BankingService {
//   static final BankingService instance = BankingService._init();
//   static Database? _database;
//   BankingService._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('banking.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE accounts (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       accno TEXT NOT NULL,
//       bankName TEXT NOT NULL,
      
//     )
//     ''');
//   }

//   Future<void> deleteBankDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'banking.db');
//     if (_database != null) {
//       await _database!.close();
//       _database = null;
//     }
//     await deleteDatabase(path);
//   }

//   // defining the schema for the stocks table
//   Future<void> createUserTable(String userName, String userPan) async {
//     final db = await instance.database;

//     await db.execute('''
//     CREATE TABLE IF NOT EXISTS banks_${userPan} (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       fdNo TEXT NOT NULL,
//       bankName NOT NULL,
//       depositDate TEXT NOT NULL,
//       depositAmount REAL NOT NULL,
//       roi REAL NOT NULL,
//       dueDate REAL NOT NULL,
//       sellQnty REAL,
//       remaining REAL,
//     )
//     ''');
//   }
// }
