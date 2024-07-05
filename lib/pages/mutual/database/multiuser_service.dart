import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'package:mutual_funds/model/stock.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mutual.db');
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

// function to delete the entire database for testing purpose only
// don't include in production code without warnings!!!!
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mutual.db');
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
    CREATE TABLE IF NOT EXISTS stocks_${userId} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      folioNo NOT NULL,
      buyDate TEXT NOT NULL,
      buyAmount REAL NOT NULL,
      buyUnitPrice REAL NOT NULL,
      buyQnty REAL NOT NULL,
      sellDate REAL,
      sellUnitPrice REAL,
      sellAmount REAL,
      sellQnty REAL,
      remaining REAL,
      currPrice REAL,
      pl REAL
    )
    ''');
  }

// a table that contains only the names of the stock that belong to a particular stock brocker
// under a particular PAN no
  Future<void> createMFNameTable(String folioNo, String userPan) async {
    final db = await instance.database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS stocks_${folioNo}_${userPan} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      schemeName TEXT NOT NULL
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
      String folioNo, String userPan, String schemeName) async {
    await createMFNameTable(folioNo, userPan);
    final db = await instance.database;
    await db.insert(
      'stocks_${folioNo}_${userPan}',
      {'schemeName': schemeName},
    );
  }

// function to delete a stockname from the initial list shown if no longer needed
  Future<void> deleteStockName(
      String userPan, String id, String schemeName) async {
    final db = await instance.database;
    await db.delete('stocks_${schemeName}_${userPan}',
        where: 'schemeName=?', whereArgs: [id]);
    await db.delete('stocks_${userPan}', where: 'name=?', whereArgs: [id]);
  }

// function to retrieve the stock names only
  Future<List<Map<String, dynamic>>> getStockName(
      String folioNo, String userPan) async {
    final db = await instance.database;
    try {
      return await db.query('stocks_${folioNo}_${userPan}',
          distinct: true, columns: ['schemeName'], orderBy: 'schemeName');
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
  Future<void> addUser(String userName, String userId) async {
    final db = await instance.database;

    await db.insert(
      'users',
      {
        'name': userName,
        'idno': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create user-specific table

    await createUserTable(userName, userId);
  }

// delete an existing user
  Future<void> deleteUser(String userName, String userPan) async {
    final db = await instance.database;
    await db.delete('users', where: 'name=?', whereArgs: [userName]);
    await db.rawDelete(
        'DELETE FROM stocks_${userPan} WHERE folioNo = ?', [userName]);
    // await db.rawQuery('DROP TABLE ${userPan}_stocks');
  }

// delete an existing user
  Future<void> deletePAN(String userPan) async {
    final db = await instance.database;
    await db.delete('users', where: 'idno=?', whereArgs: [userPan]);
    await db.rawQuery('DROP TABLE stocks_${userPan}');
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

  // Future<Map<String, List<String>>> getMfUsersGroupedByPanNo() async {
  //   // Query to get the data grouped by panNo
  //   final db = await instance.database;
  //   final List<Map<String, dynamic>> result = await db.rawQuery('''
  //   SELECT idno, name
  //   FROM users
  //   ORDER BY idno, name
  // ''');

  // Transform the result into a Map
  //   Map<String, List<String>> groupedData = {};
  //   for (var row in result) {
  //     final String panNo = row['idno'];
  //     final String brokername = row['name'];
  //     if (!groupedData.containsKey(panNo)) {
  //       groupedData[panNo] = [];
  //     }
  //     groupedData[panNo]!.add(brokername);
  //   }

  //   return groupedData;
  // }

// insert stocks
  Future<void> insertStock(String userPan, Map<String, dynamic> stock) async {
    final db = await instance.database;
    // Check for existing stocks with the same name
    final List<Map<String, dynamic>> existingStocks = await db.query(
      'stocks_${userPan}',
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
          stock['pl'] = ((existingStock['currPrice'] * stock['buyQnty'] -
                      stock['buyUnitPrice'] * stock['buyQnty']) /
                  (stock['buyAmount'])) *
              100;
          break;
        }
      }
    }
    await db.insert(
      'stocks_${userPan}',
      stock,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await addFY(stock['buyDate']);
  }

// get a single stock value to show the company names in a grouped fashion
  Future<List<Map<String, dynamic>>> getSingleStock(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.query('stocks_${userPan}',
        where: 'name=? and folioNo=? and remaining >0',
        whereArgs: [stockName, userName]);
  }

// get a single stock value to show the company names in a grouped fashion
  Future<List<Map<String, dynamic>>> getSingleStockSold(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.query('stocks_${userPan}',
        where: 'name=? and folioNo=? and remaining=0',
        whereArgs: [stockName, userName]);
  }

// get a filtered list of mutual funds from the db
  Future<List<Map<String, dynamic>>> getFilteredFunds(String userName,
      String userPan, String stockName, String start, String end) async {
    final db = await instance.database;

    return await db.query('stocks_${userPan}',
        where:
            'name=? and folioNo=? and remaining>0 and buyDate between ? and ?',
        whereArgs: [stockName, userName, start, end]);
  }

// method to show the total invested and profit
  Future<List<Map<String, dynamic>>> getTotalStockOverview(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;

    return await db.rawQuery(
        "SELECT sum(buyUnitPrice*buyQnty) as totalInv FROM stocks_${userPan}  WHERE name=? and folioNo=? and remaining >0",
        [stockName, userName]);
  }

// sell a batch of stock and update the fields sell date and price
  Future<void> sellStock(String userName, String userPan, int stockId,
      double unitPrice, String date) async {
    final db = await instance.database;

    await db.rawUpdate('''
  UPDATE stocks_${userPan} 
  SET 
    remaining = 0, 
    sellDate = ?, 
    sellUnitPrice = ?, 
    sellQnty = buyQnty 
  WHERE id = ?
  ''', [date, unitPrice, stockId]);
    await db.rawQuery(
        "UPDATE stocks_${userPan} set pl = ((sellUnitPrice*buyQnty - buyAmount)/(buyAmount))*100 where id=?",
        [stockId]);
    await addFY(date);
  }

// sell a batch of stock and update the fields sell date and price
  Future<void> sellFilteredStock(String userName, String userPan,
      List<Map<String, dynamic>> stocks, double unitPrice, String date) async {
    final db = await instance.database;

    for (var stock in stocks) {
      await db.rawUpdate('''
  UPDATE stocks_${userPan} 
  SET 
    remaining = 0, 
    sellDate = ?, 
    sellUnitPrice = ?, 
    sellQnty = buyQnty 
  WHERE id = ?
  ''', [date, unitPrice, stock['id']]);
      await db.rawQuery(
          "UPDATE stocks_${userPan} set pl = ((sellUnitPrice*buyQnty - buyAmount)/(buyAmount))*100 where id=?",
          [stock['id']]);
    }
    await addFY(date);
  }

// sell a batch of stock and update the fields sell date and price
  Future<void> updateStock(String userName, String userPan, int stockId,
      double unitPrice, double quantity) async {
    final db = await instance.database;

    await db.rawUpdate('''
  UPDATE stocks_${userPan} 
  SET 
    remaining = ?, 
    buyUnitPrice=?,
    buyAmount=?
  WHERE id = ?
  ''', [quantity, unitPrice, unitPrice, stockId]);
    await db.rawQuery(
        "UPDATE stocks_${userPan} set pl = ((currPrice*buyAmount - buyPrice*buyAmount)/(buyPrice*buyAmount))*100 where id=?",
        [stockId]);
    // await addFY(date);
  }

// delete an already made stock in case of wrongly inputting
  Future<void> deleteBatch(String userPan, int stockId) async {
    final db = await instance.database;

    await db.delete('stocks_${userPan}', where: 'id=?', whereArgs: [stockId]);
  }

// update the current price field to calculate profit/loss
  Future<void> addCurrPrice(
      String userName, String userPan, String name, double currPrice) async {
    final db = await instance.database;
    await db.update(
      'stocks_${userPan}',
      {
        'currPrice': currPrice,
      },
      where: 'name=? ',
      whereArgs: [name],
    );
    await db.rawQuery(
        "UPDATE stocks_${userPan} set pl = ((currPrice * buyQnty - buyAmount)/(buyAmount))*100 where name=? and remaining>0",
        [name]);
  }

// method to calculate profit/loss
  Future<List<Map<String, dynamic>>> getPL(
      String userName, String userPan, String stockName, int id) async {
    final db = await instance.database;

    return await db.rawQuery(
        "SELECT name,pl FROM stocks_${userPan}  WHERE name=? and id=?",
        [stockName, id]);
  }

// to show the total quantity of a particular stock that is bought
  Future<List<Map<String, dynamic>>> getTotalQuantity(
      String userName, String userPan) async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT name, SUM(buyAmount) as total_quantity FROM stocks_${userPan} where folioNo=?  GROUP BY name HAVING SUM(buyAmount) > 0 ',
      [userName],
    );
  }

// show the average buy amount by excluding the stocks that are already sold
  Future<List<Map<String, dynamic>>> getBuyAvg(
      String userName, String userPan, String stockName) async {
    final db = await instance.database;
    return await db.rawQuery(
        'SELECT sum(buyAmount)/sum(buyQnty) as avg FROM stocks_${userPan} where name=? and remaining>0;',
        [stockName]);
  }

  Future<List<Map<String, dynamic>>> fetchYears(String userPan) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR(buyDate, 1, 4) AS year FROM stocks_${userPan};');
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchFinancialYearWiseDataPL(
      String userPan, String brokerName, int date) async {
    String start = '${date - 1}-04-01';
    String end = '$date-03-31';
    final db = await instance.database;
    final result = await db.query('stocks_${userPan}',
        where:
            'folioNo = ?  and remaining = 0 and sellDate BETWEEN ? AND ? order by name',
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
    SELECT * FROM stocks_${userPan}
    WHERE folioNo=? and (buyDate <= ? AND (sellDate IS NULL OR (not sellDate < ? and sellDate not between ? and ?)))
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
