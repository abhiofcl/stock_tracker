// defining structure for the database table
// name for the table
const String tableName = "stocks";

//various fields related to the table
const String idField = "_id";
const String nameField = "name";
const String buyamountField = "buy_date";
const String buydateField = "buy_amount";
const String amountField = "amount";
const String sellamountField = "sell_amount";
const String selldateField = "sell_date";

const List<String> stockColumn = [
  idField,
  nameField,
  buyamountField,
  buydateField,
  amountField,
  sellamountField,
  selldateField,
];

// defining the datatypes for the various columns
const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String textType = "TEXT NOT NULL";
const String doubleType = "";

// class representing the various data associated with each stock
// sell amount and sell date are optional
class Stock {
  final int id;
  final String name;
  final double buyAmount;
  final String boughtDate;
  final double amount;
  final String? sellAmount;
  final String? sellDate;

  const Stock({
    required this.id,
    required this.name,
    required this.buyAmount,
    required this.boughtDate,
    required this.amount,
    this.sellAmount,
    this.sellDate,
  });
}
