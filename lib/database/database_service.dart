import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// var databasePath = awaut getData
// class DataBaseService {
//   Database? _database;
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initialize();
//     return _database!;
//   }
// }
class DataBaseService {
  static final DataBaseService instance = DataBaseService._constructor();
  final String _tableName = "stocks";

  static Database? _db;
  final String _idField = "_id";
  final String _nameField = "name";
  final String _buypriceField = "buy_date";
  final String _buydateField = "buy_price";
  final String _buyamountField = "buy_amount";
  final String _sellpriceField = "sell_price";
  final String _sellamountField = "sell_amount";
  final String _selldateField = "sell_date";
  final String _remainingStock = "remaining";

  DataBaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final dataBaseDirPath = await getDatabasesPath();
    final dataBasePath = join(dataBaseDirPath, "master_db.db");

    final database = await openDatabase(
      dataBasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
CREATE TABLE $_tableName (
  $_idField INTEGER PRIMARY KEY,
  $_nameField TEXT NOT NULL,
  $_buypriceField REAL NOT NULL,
  $_buydateField TEXT NOT NULL,
  $_buyamountField REAL NOT NULL,
  $_sellamountField REAL ,
  $_sellpriceField REAL,
  $_selldateField TEXT ,
  $_remainingStock REAL,
)
''');
      },
    );
    return database;
  }

  void addStock(name, amount, buyprice, buydate) async {
    String formattedDate =
        "${buydate.year}-${buydate.month.toString().padLeft(2, '0')}-${buydate.day.toString().padLeft(2, '0')}";
    final db = await database;
    await db.insert(_tableName, {
      _nameField: name,
      _buyamountField: amount,
      _buypriceField: buyprice,
      _buydateField: formattedDate,
      _remainingStock: 0,
      _sellamountField: 0,
      _selldateField: 0,
      _sellpriceField: 0,
    });
  }
}
