import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'package:stock_tracker/model/stock.dart';

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
      idno TEXT NOT NULL,
      val INTEGER NOT NULL
    )
    ''');
  }

// function to delete the entire database for testing purpose only
// don't include in production code without warnings!!!!
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trading.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }

// defining the schema for the stocks table
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

// defining the schema for the table
  Future<void> createUserMFTable(String userName, String userId) async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS mfs_${userId} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      schemeName NOT NULL,
      buyPrice REAL NOT NULL,
      buyDate TEXT NOT NULL,
      buyUnits REAL NOT NULL,
      sellPrice REAL,
      sellDate REAL,
      sellQnty REAL,
      remaining REAL,
      currPrice REAL,
      pl REAL
    )
    ''');
  }

// a table that contains only the names of the stock that belong to a particular stock brocker
// under a particular PAN no
  Future<void> createStockNameTable(String brockerName, String userId) async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS stocks_${brockerName}_${userId} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stockName TEXT NOT NULL
    )
    ''');
  }

// function to create a table which contains all the Financial Years that are
// related to the data already entered into the code.
  Future<void> createFYTable() async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS fy_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fy TEXT 
    )
    ''');
  }

// function that adds the FYs to the FY table when a new stock is bought or sold
  Future<void> addFY(String date) async {
    int year = int.parse(date.substring(0, 4));
    DateTime dt = DateTime.parse(date);
    String start = '$year-03-31';
    String end = '${year + 1}-03-31';
    final db = await instance.database;
    await createFYTable();

    if (dt.isAfter(DateTime.parse(start)) && dt.isBefore(DateTime.parse(end))) {
      await db.insert('fy_table', {
        'fy': (year + 1).toString(),
      });
    } else {
      await db.insert('fy_table', {
        'fy': (year).toString(),
      });
    }
  }

// function to retrieve all the FYs from the table to show in
// statement generator
  Future<List<Map<String, dynamic>>> getFY(String userPan) async {
    final db = await instance.database;
    try {
      return await db
          .rawQuery('SELECT DISTINCT fy FROM fy_table ORDER BY fy DESC');
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError()) {
        // Table does not exist, return an empty list
        return [];
      } else {
        // Handle other database exceptions
        throw e;
      }
    }
  }

// function to add only the names of stocks added for a particular broker
  Future<void> addStockname(
      String brockerName, String userId, String stockName) async {
    await createStockNameTable(brockerName, userId);
    final db = await instance.database;
    await db.insert(
      'stocks_${brockerName}_${userId}',
      {'stockName': stockName},
    );
  }

// function to delete a stockname from the initial list shown if no longer needed
  Future<void> deleteStockName(
      String userPan, String id, String brockerName) async {
    final db = await instance.database;
    await db.delete('stocks_${brockerName}_${userPan}',
        where: 'stockName=?', whereArgs: [id]);
  }

// function to retrieve the stock names only
  Future<List<Map<String, dynamic>>> getStockName(
      String brockername, String userPan) async {
    final db = await instance.database;
    try {
      return await db.query('stocks_${brockername}_${userPan}',
          distinct: true, columns: ['stockName'], orderBy: 'stockName');
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError()) {
        // Table does not exist, return an empty list
        return [];
      } else {
        // Handle other database exceptions
        throw e;
      }
    }
  }

// add a new user account
  Future<void> addUser(String userName, String userId, int val) async {
    final db = await instance.database;

    await db.insert(
      'users',
      {'name': userName, 'idno': userId, 'val': val},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create user-specific table
    if (val == 1) {
      await createUserTable(userName, userId);
    } else {
      await createUserMFTable(userName, userId);
    }
  }

// add a new user account for Mutual Fund
  Future<void> addMFUser(String schemeName, String userId) async {
    final db = await instance.database;

    await db.insert(
      '${userId}_mfs',
      {'name': schemeName, 'idno': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create user-specific table
    await createUserMFTable(schemeName, userId);
  }

// delete an existing user
  Future<void> deleteUser(String userName, String userPan) async {
    final db = await instance.database;
    await db.delete('users', where: 'name=?', whereArgs: [userName]);
    await db.rawDelete(
        'DELETE FROM ${userPan}_stocks WHERE brockerName = ?', [userName]);
    // await db.rawQuery('DROP TABLE ${userPan}_stocks');
  }

// delete an existing user
  Future<void> deletePAN(String userPan) async {
    final db = await instance.database;
    await db.delete('users', where: 'idno=?', whereArgs: [userPan]);
    await db.rawQuery('DROP TABLE ${userPan}_stocks');
  }
  // Future<List<Map<String, dynamic>>> getUsers() async {
  //   final db = await instance.database;
  //   return await db.query('users');
  // }

  Future<Map<String, List<String>>> getUsersGroupedByPanNo() async {
    // Query to get the data grouped by panNo
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT idno, name
    FROM users
    where val=1
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

  Future<Map<String, List<String>>> getMfUsersGroupedByPanNo() async {
    // Query to get the data grouped by panNo
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT idno, name
    FROM users
    where val=2
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
    await addFY(stock['buyDate']);
  }

// insert MF
  Future<void> insertMF(String userId, Map<String, dynamic> stock) async {
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
    await addFY(stock['buyDate']);
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
      String userPan, String userName, String stockName) async {
    final db = await instance.database;

    return await db.query(
      '${userName}_stocks',
      where: 'name =? and remaining = 0',
      whereArgs: [stockName],
    );
  }

//get all stocks of a particular stock with holdings(ie already not sold stocks)
  Future<List<Map<String, dynamic>>> getHoldingStocks(
      String userPan, String userName, String stockName) async {
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

    return await db.query('${userPan}_stocks',
        where: 'name=? and brockerName=? and remaining >0',
        whereArgs: [stockName, userName]);
  }

// get a single stock value to show the company names in a grouped fashion
  Future<List<Map<String, dynamic>>> getSingleStockSold(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.query('${userPan}_stocks',
        where: 'name=? and brockerName=? and remaining=0',
        whereArgs: [stockName, userName]);
  }

// method to show the total invested and profit
  Future<List<Map<String, dynamic>>> getTotalStockOverview(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.rawQuery(
        "SELECT sum(buyPrice*buyAmount) as totalInv FROM ${userPan}_stocks  WHERE name=? and brockerName=? and remaining >0",
        [stockName, userName]);
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
    await addFY(date);
  }

// sell a batch of stock and update the fields sell date and price
  Future<void> updateStock(String userName, String userPan, int stockId,
      double amount, double quantity) async {
    final db = await instance.database;

    await db.rawUpdate('''
  UPDATE ${userPan}_stocks 
  SET 
    remaining = ?, 
    buyAmount=?,
    buyPrice=?
  WHERE id = ?
  ''', [quantity, quantity, amount, stockId]);
    await db.rawQuery(
        "UPDATE ${userPan}_stocks set pl = ((currPrice*buyAmount - buyPrice*buyAmount)/(buyPrice*buyAmount))*100 where id=?",
        [stockId]);
    // await addFY(date);
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
      where: 'name=? ',
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
        'SELECT sum(buyamount*buyprice)/sum(remaining) as avg FROM ${userPan}_stocks where name=? and remaining>0;',
        [stockName]);
  }

  // query for generating statement
  // Future<List<Map<String, dynamic>>> fetchFinancialYearDataPL(
  //     String userPan, String date) async {
  //   final db = await instance.database;
  //   final result = await db.query(
  //     '${userPan}_stocks',
  //     where: 'remaining = 0',
  //   ); // Adjust the query as needed
  //   return result;
  // }

  // Future<List<Map<String, dynamic>>> fetchFinancialYearDataHold(
  //     String userPan, String date) async {
  //   final db = await instance.database;
  //   final List<Map<String, dynamic>> existingStocks = await db.query(
  //     '${userPan}_stocks',
  //     // columns: [
  //     //   'name',
  //     //   'buyDate',
  //     //   'sellDate',
  //     //   'remaining',
  //     // ],
  //     // where: 'sellDate ',
  //     // whereArgs: [
  //       // stock['name'],
  //     // ],
  //   );

  //   final result = await db.query(
  //     '${userPan}_stocks',
  //     where: 'remaining > 0',
  //   ); // Adjust the query as needed
  //   return result;
  // }

  Future<List<Map<String, dynamic>>> fetchYears(String userPan) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR(buyDate, 1, 4) AS year FROM ${userPan}_stocks;');
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchFinancialYearWiseDataPL(
      String userPan, String brokerName, int date) async {
    String start = '${date - 1}-04-01';
    String end = '$date-03-31';
    final db = await instance.database;
    final result = await db.query('${userPan}_stocks',
        where:
            'brockerName = ?  and remaining = 0 and sellDate BETWEEN ? AND ? order by name',
        whereArgs: [brokerName, start, end]); // Adjust the query as needed
    return result;
  }

  // Future<List<Map<String, dynamic>>> fetchFinancialYearWiseDataHold(
  //     String userPan, int date) async {
  //   // String start = (date - 1).toString() + '-04-01';
  //   String end = '$date-03-31';
  //   final db = await instance.database;
  //   final result = await db.query('${userPan}_stocks',
  //       where: 'remaining > 0 and buyDate<=?',
  //       whereArgs: [end]); // Adjust the query as needed
  //   return result;
  // }
  Future<List<Map<String, dynamic>>> fetchFinancialYearWiseDataHold(
      String userPan, String brokerName, int year) async {
    String start = '${year - 1}-04-01';
    String end = '$year-03-31';
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT * FROM ${userPan}_stocks
    WHERE brockerName=? and (buyDate <= ? AND (sellDate IS NULL OR (not sellDate < ? and sellDate not between ? and ?)))
    order BY name
  ''', [brokerName, end, start, start, end]);

    return result;
  }

  // Future<List<Map<String, dynamic>>> fetchFinancialYearWiseDataHold(
  //     String userPan, int date) async {
  //   String start = (date - 1).toString() + '-04-01';
  //   String end = '$date-03-31';
  //   DateTime startP = DateTime.parse(start);
  //   DateTime endP = DateTime.parse(end);
  //   int flag = 0;
  //   final db = await instance.database;
  //   List<Map<String, dynamic>> result = [];

  //   final List<Map<String, dynamic>> existingStocks = await db.query(
  //     '${userPan}_stocks',
  //     // columns: [
  //     //   'name',
  //     //   'buyDate',
  //     //   'sellDate',
  //     //   'remaining',
  //     // ],
  //     // where: 'sellDate ',
  //     // whereArgs: [
  //     // stock['name'],
  //     // ],
  //   );
  //   if (existingStocks.isNotEmpty) {
  //     // Check if any of the existing stocks have a non-empty currentPrice
  //     for (var existingStock in existingStocks) {
  //       if (existingStock['sellDate'] != null &&
  //           existingStock['sellDate'] != '') {
  //         // Duplicate the currentPrice
  //         result = await db.query('${userPan}_stocks',
  //             orderBy: 'name',
  //             where: 'sellDate>=? and buyDate<=? and sellDate is not null',
  //             whereArgs: [end, end]);
  //       } else {
  //         result = await db.query('${userPan}_stocks',
  //             orderBy: 'name',
  //             where: 'buyDate<=? and sellDate is null',
  //             whereArgs: [end]); // Adjust the query as needed
  //       }
  //     }
  //   }

  //   return result;
  // }
}
