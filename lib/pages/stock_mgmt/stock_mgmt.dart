import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_tracker/database/multiuser_service.dart';
import 'package:stock_tracker/pages/stock_mgmt/Statements.dart';

class SavedStockScreen extends StatefulWidget {
  final String userName;
  final String stockName;
  final String userPan;

  const SavedStockScreen(
      {super.key,
      required this.userName,
      required this.stockName,
      required this.userPan});

  @override
  State<SavedStockScreen> createState() => _SavedStockScreenState();
}

class _SavedStockScreenState extends State<SavedStockScreen> {
  List<Map<String, dynamic>> stocks = [];
  // DateTime? _selectedDate;
  String? _formattedDate;
  final TextEditingController _sellAmountController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();
  final TextEditingController _currPriceController = TextEditingController();
  late double buyAvg = 0.0;
  late double totalInvested = 0.0;
  double? pl = 0.0;
  late double currPrice = 0;
  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    try {
      final dbStocks = await DatabaseService.instance
          .getSingleStock(widget.userName, widget.userPan, widget.stockName);
      final buya = await DatabaseService.instance
          .getBuyAvg(widget.userName, widget.userPan, widget.stockName);
      final totalInv = await DatabaseService.instance.getTotalStockOverview(
          widget.userName, widget.userPan, widget.stockName);

      setState(() {
        if (dbStocks.isNotEmpty && totalInv.isNotEmpty && buya.isNotEmpty) {
          stocks = dbStocks;
          buyAvg = buya[0]['avg'] ?? 0;
          totalInvested = totalInv[0]['totalInv'] ?? 0;
          currPrice = dbStocks[0]['currPrice'] ?? 2;
        } else {
          stocks = [];
          buyAvg = 0;
          totalInvested = 0;
          currPrice = 1;
        }
      });
    } catch (e) {
      debugPrint("error");
    }
  }

  Future<void> _sellStock(int id, String amount, String date) async {
    await DatabaseService.instance.sellStock(
        widget.userName, widget.userPan, id, double.parse(amount), date);
    _loadStocks();
  }

  Future<void> _deleteStock(int id) async {
    await DatabaseService.instance.deleteBatch(widget.userPan, id);
    _loadStocks();
  }

  Future<void> _setCurrentPrice(String amount) async {
    await DatabaseService.instance.addCurrPrice(widget.userName, widget.userPan,
        widget.stockName, double.parse(amount));
    _loadStocks();
    setState(() {
      currPrice = double.parse(amount);
    });
  }

  // Future<void> _setPL(int id) async {
  //   final plOb = await DatabaseService.instance
  //       .getPL(widget.userName, widget.stockName, id);
  //   setState(() {
  //     pl = plOb[''];
  //   });
  //   _loadStocks();
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // _selectedDate = picked;
        _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Holding stocks"),
        // actions: <Widget>[
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context,
        //             MaterialPageRoute(builder: (BuildContext context) {
        //           return Statement(
        //             userName: widget.userName,
        //             userPan: widget.userPan,
        //             stockName: widget.stockName,
        //           );
        //         }));
        //       },
        //       icon: const Icon(Icons.menu_book))
        // ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.monetization_on_outlined),
        onPressed: () => _showCurrPriceDialog(context),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock Overview',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Buy AVG: $buyAvg'),
                      const SizedBox(height: 8.0),
                      Text('Total Invested : $totalInvested'),
                      const SizedBox(height: 8.0),
                      Text("Current Price:$currPrice"),
                      const SizedBox(height: 8.0),
                      const Text('Total returns:'),

                      // Add more overview details as needed
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Profit"),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: Colors.green[300]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Loss"),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: Colors.red[300]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Sold"),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: Colors.teal[100]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showBottomBorder: true,
                    border: TableBorder.all(
                      borderRadius: BorderRadius.circular(8),
                      width: 1,
                    ),
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromARGB(255, 144, 150, 202)),
                    columns: const [
                      DataColumn(label: Text('Buy Date')),
                      DataColumn(label: Text('Buy Quantity')),
                      DataColumn(label: Text('Buy Price')),
                      DataColumn(label: Text('Invested Amount')),
                      DataColumn(label: Text('Present Value')),
                      DataColumn(label: Text('P/L')),
                      DataColumn(label: Text('% P/L')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      stocks.length,
                      (index) {
                        final stock = stocks[index];
                        final String formattedDate = DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(stock['buyDate']));
                        final String formattedSellDate =
                            stock['sellDate'] != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(stock['sellDate']))
                                : 'N/A';
                        double value = stock['pl'] ?? 0;
                        final formattedValue = value.toStringAsFixed(2);
                        double pl = ((stock['pl'] ?? 0) *
                                stock['buyPrice'] *
                                stock['buyAmount'] /
                                100) ??
                            0;
                        final formattedPl = pl.toStringAsFixed(2);
                        double rem = stock['remaining'];

                        return DataRow(
                          cells: [
                            DataCell(Text(formattedDate)),
                            DataCell(Text('${stock['buyAmount']}')),
                            DataCell(Text('${stock['buyPrice']}')),
                            DataCell(
                              Text(
                                (stock['buyAmount'] * stock['buyPrice'])
                                    .toString(),
                              ),
                            ),
                            DataCell(Text(
                                ((stock['currPrice'] ?? 0) * stock['buyAmount'])
                                        ?.toString() ??
                                    'N/A')),
                            DataCell(Text('$formattedPl')),
                            DataCell(Text('$formattedValue')),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (String result) {
                                  switch (result) {
                                    case 'Modify':
                                      _showModifyDialog(context);
                                      break;
                                    case 'Sell':
                                      _showSellDialog(context, index);
                                      break;
                                    case 'Delete':
                                      _deleteStock(stock['id']);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Modify',
                                    child: Text('Modify'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Sell',
                                    child: Text('Sell'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          color: MaterialStateColor.resolveWith(
                            (states) => rem > 0
                                ? value >= 0
                                    ? Colors.green[300]!
                                    : Colors.red[300]!
                                : Colors.teal[100]!,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSellDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sell Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _sellAmountController,
                decoration: const InputDecoration(
                  labelText: 'Sell Price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              // TextFormField(
              //   controller: _dateController,
              //   readOnly: true,
              //   decoration: const InputDecoration(
              //     labelText: 'Sell Date',
              //   ),
              //   keyboardType:
              //       const TextInputType.numberWithOptions(decimal: true),
              // ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_formattedDate ?? 'Select Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                // final String formattedDate = DateFormat('yyyy-MM-dd')
                //     .format();
                // print(_dateController.text);
                _sellStock(
                  stocks[index]['id'],
                  _sellAmountController.text,
                  _formattedDate!,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showModifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modify Item'),
          content: const Text('You selected to modify the item.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this batch?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                _deleteStock(stocks[index]['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCurrPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Current Price'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _currPriceController,
              decoration: const InputDecoration(
                labelText: 'Set Current Price',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ]),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Handle OK action
                _setCurrentPrice(_currPriceController.text);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
