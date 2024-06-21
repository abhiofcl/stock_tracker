import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stock_tracker/model/stock.dart';

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

  Future<void> createUserTable(String userName, String userId) async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${userId}_stocks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      brockerName NOT NULL,
      buyPrice REAL NOT NULL,
      buyDate TEXT NOT NULL,
      buyAmount REAL NOT NULL,
      sellPrice REAL,
      sellDate REAL,
      sellQnty REAL,
      remaining REAL,
      currPrice REAL,
      pl REAL
    )
    ''');
  }

// add a new user account
  Future<void> addUser(String userName, String userId) async {
    final db = await instance.database;

    await db.insert(
      'users',
      {'name': userName, 'idno': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create user-specific table
    await createUserTable(userName, userId);
  }

// delete an existing user
  Future<void> deleteUser(String userName, String userPan) async {
    final db = await instance.database;
    await db.delete('users', where: 'name=?', whereArgs: [userName]);
    await db.rawQuery('DROP TABLE ${userPan}_stocks');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;

    return await db.query('users');
  }

  Future<Map<String, List<String>>> getUsersGroupedByPanNo() async {
    // Query to get the data grouped by panNo
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT idno, name
    FROM users
    ORDER BY idno, name
  ''');

    // Transform the result into a Map
    Map<String, List<String>> groupedData = {};
    for (var row in result) {
      final String panNo = row['idno'];
      final String brokername = row['name'];
      if (!groupedData.containsKey(panNo)) {
        groupedData[panNo] = [];
      }
      groupedData[panNo]!.add(brokername);
    }

    return groupedData;
  }

// insert stocks
  Future<void> insertStock(String userId, Map<String, dynamic> stock) async {
    final db = await instance.database;
    // Check for existing stocks with the same name
    final List<Map<String, dynamic>> existingStocks = await db.query(
      '${userId}_stocks',
      where: 'name = ?',
      whereArgs: [
        stock['name'],
      ],
    );
    if (existingStocks.isNotEmpty) {
      // Check if any of the existing stocks have a non-empty currentPrice
      for (var existingStock in existingStocks) {
        if (existingStock['currPrice'] != null &&
            existingStock['currPrice'] != '') {
          // Duplicate the currentPrice
          stock['currPrice'] = existingStock['currPrice'];
          stock['pl'] = ((existingStock['currPrice'] * stock['buyAmount'] -
                      stock['buyPrice'] * stock['buyAmount']) /
                  (stock['buyPrice'] * stock['buyAmount'])) *
              100;
          break;
        }
      }
    }
    await db.insert(
      '${userId}_stocks',
      stock,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// get all stocks of a particular stock
  Future<List<Map<String, dynamic>>> getAllStocks(String userName) async {
    final db = await instance.database;

    return await db.query(
      '${userName}_stocks',
      where: 'remaining > ?',
      whereArgs: [0],
    );
  }

//get all stocks of a particular stock with p/l(ie already sold stocks)
  Future<List<Map<String, dynamic>>> getPLStocks(
      String userName, String stockName) async {
    final db = await instance.database;

    return await db.query(
      '${userName}_stocks',
      where: 'name =? and remaining = 0',
      whereArgs: [stockName],
    );
  }

//get all stocks of a particular stock with holdings(ie already not sold stocks)
  Future<List<Map<String, dynamic>>> getHoldingStocks(
      String userName, String stockName) async {
    final db = await instance.database;

    return await db.query(
      '${userName}_stocks',
      where: 'name =? and remaining > 0',
      whereArgs: [stockName],
    );
  }

// get a single stock value to show the company names in a grouped fashion
  Future<List<Map<String, dynamic>>> getSingleStock(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db
        .query('${userPan}_stocks', where: 'name=?', whereArgs: [stockName]);
  }

// method to show the totoal invested and profit
  Future<List<Map<String, dynamic>>> getTotalStockOverview(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.rawQuery(
        "SELECT sum(buyPrice*buyAmount) as totalInv FROM ${userPan}_stocks  WHERE name=?",
        [stockName]);
  }

// sell a batch of stock and update the fields sell date and price
  Future<void> sellStock(String userName, String userPan, int stockId,
      double amount, String date) async {
    final db = await instance.database;

    await db.rawUpdate('''
  UPDATE ${userPan}_stocks 
  SET 
    remaining = 0, 
    sellDate = ?, 
    sellPrice = ?, 
    sellQnty = buyAmount 
  WHERE id = ?
  ''', [date, amount, stockId]);
    await db.rawQuery(
        "UPDATE ${userPan}_stocks set pl = ((sellPrice*buyAmount - buyPrice*buyAmount)/(buyPrice*buyAmount))*100 where id=?",
        [stockId]);
  }

// delete an already made stock in case of wrongly inputting
  Future<void> deleteBatch(String userPan, int stockId) async {
    final db = await instance.database;

    await db.delete('${userPan}_stocks', where: 'id=?', whereArgs: [stockId]);
  }

// update the current price field to calculate profit/loss
  Future<void> addCurrPrice(
      String userName, String userPan, String name, double currPrice) async {
    final db = await instance.database;
    await db.update(
      '${userPan}_stocks',
      {
        'currPrice': currPrice,
      },
      where: 'name=? and remaining >0',
      whereArgs: [name],
    );
    await db.rawQuery(
        "UPDATE ${userPan}_stocks set pl = ((currPrice*buyAmount - buyPrice*buyAmount)/(buyPrice*buyAmount))*100 where name=? and remaining>0",
        [name]);
  }

// method to calculate profit/loss
  Future<List<Map<String, dynamic>>> getPL(
      String userName, String userPan, String stockName, int id) async {
    final db = await instance.database;

    return await db.rawQuery(
        "SELECT name,pl FROM ${userPan}_stocks  WHERE name=? and id=?",
        [stockName, id]);
  }

// to show the total quantity of a particular stock that is bought
  Future<List<Map<String, dynamic>>> getTotalQuantity(
      String userName, String userPan) async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT name, SUM(buyAmount) as total_quantity FROM ${userPan}_stocks where brockerName=?  GROUP BY name HAVING SUM(buyAmount) > 0 ',
      [userName],
    );
  }

// show the average buy amount by excluding the stocks that are already sold
  Future<List<Map<String, dynamic>>> getBuyAvg(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;
    return await db.rawQuery(
        'SELECT sum(buyamount*buyprice) /sum(remaining) as avg FROM ${userPan}_stocks where name=? and remaining>0;',
        [stockName]);
  }

  // query for generating statement
  Future<List<Map<String, dynamic>>> fetchFinancialYearDataPL(
      String userPan, String date) async {
    final db = await instance.database;
    final result = await db.query(
      '${userPan}_stocks',
      where: 'remaining = 0',
    ); // Adjust the query as needed
    return result;
  }

  // Future<List<Map<String, dynamic>>> fetchFinancialYearDataPL(
  //     String userName, String date) async {
  //   final db = await instance.database;
  //   final result = await db.query(
  //     '${userName}_stocks',
  //     where: 'remaining = 0 AND buyDate<=?',
  //     whereArgs: [date],
  //   ); // Adjust the query as needed
  //   return result;
  // }
  Future<List<Map<String, dynamic>>> fetchFinancialYearDataHold(
      String userPan, String date) async {
    final db = await instance.database;
    final result = await db.query(
      '${userPan}_stocks',
      where: 'remaining > 0',
    ); // Adjust the query as needed
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchYears(String userPan) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR(buyDate, 1, 4) AS year FROM ${userPan}_stocks;');
    return result;
  }
}
