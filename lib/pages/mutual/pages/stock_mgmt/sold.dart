import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_tracker/pages/mutual/database/multiuser_service.dart';
import 'package:stock_tracker/pages/mutual/pages/stock_mgmt/Statements.dart';

class SoldStockScreen extends StatefulWidget {
  final String userName;
  final String stockName;
  final String userPan;

  const SoldStockScreen(
      {super.key,
      required this.userName,
      required this.stockName,
      required this.userPan});

  @override
  State<SoldStockScreen> createState() => _SoldStockScreenState();
}

class _SoldStockScreenState extends State<SoldStockScreen> {
  List<Map<String, dynamic>> stocks = [];
  String? _formattedDate;
  final TextEditingController _sellAmountController = TextEditingController();
  double? pl = 0.0;
  // final TextEditingController _dateController = TextEditingController();
  // final TextEditingController _currPriceController = TextEditingController();
  // late double buyAvg = 0.0;
  // late double totalInvested = 0.0;
  // DateTime? _selectedDate;
  // late double currPrice = 0;
  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    try {
      final dbStocks = await DatabaseService.instance.getSingleStockSold(
          widget.userName, widget.userPan, widget.stockName);
      // final buya = await DatabaseService.instance
      //     .getBuyAvg(widget.userName, widget.userPan, widget.stockName);
      // final totalInv = await DatabaseService.instance.getTotalStockOverview(
      //     widget.userName, widget.userPan, widget.stockName);

      setState(() {
        // if (dbStocks.isNotEmpty && totalInv.isNotEmpty && buya.isNotEmpty) {

        if (dbStocks.isNotEmpty) {
          stocks = dbStocks;
          // buyAvg = buya[0]['avg'] ?? 0;
          // totalInvested = totalInv[0]['totalInv'] ?? 0;
          // currPrice = dbStocks[0]['currPrice'] ?? 2;
        } else {
          stocks = [];
          // buyAvg = 0;
          // totalInvested = 0;
          // currPrice = 1;
        }
      });
    } catch (e) {
      debugPrint("error");
    }
  }

  // Future<void> _sellStock(int id, String amount, String date) async {
  //   await DatabaseService.instance.sellStock(
  //       widget.userName, widget.userPan, id, double.parse(amount), date);
  //   _loadStocks();
  // }

  // Future<void> _deleteStock(int id) async {
  //   await DatabaseService.instance.deleteBatch(widget.userPan, id);
  //   _loadStocks();
  // }

  // Future<void> _setCurrentPrice(String amount) async {
  //   await DatabaseService.instance.addCurrPrice(widget.userName, widget.userPan,
  //       widget.stockName, double.parse(amount));
  //   _loadStocks();
  //   setState(() {
  //     currPrice = double.parse(amount);
  //   });
  // }

  // Future<void> _setPL(int id) async {
  //   final plOb = await DatabaseService.instance
  //       .getPL(widget.userName, widget.stockName, id);
  //   setState(() {
  //     pl = plOb[''];
  //   });
  //   _loadStocks();
  // }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       // _selectedDate = picked;
  //       _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sold stocks"),
      ),
      body: Center(
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
                DataColumn(label: Text('Units')),
                DataColumn(label: Text('Unit Price')),
                DataColumn(label: Text('Buy Amount')),
                DataColumn(label: Text('Sell Date')),
                DataColumn(label: Text('Sell Qnty')),
                DataColumn(label: Text('Sell unit Price')),
                DataColumn(label: Text('Sell Amount')),
                DataColumn(label: Text('P/L')),
                DataColumn(label: Text('% P/L')),
                // DataColumn(label: Text('Actions')),
              ],
              rows: List<DataRow>.generate(
                stocks.length,
                (index) {
                  final stock = stocks[index];
                  final String formattedDate = DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(stock['buyDate']));
                  final String formattedSellDate = stock['sellDate'] != null
                      ? DateFormat('dd-MM-yyyy')
                          .format(DateTime.parse(stock['sellDate']))
                      : 'N/A';
                  double value = stock['pl'] ?? 0;
                  final formattedValue = value.toStringAsFixed(2);
                  double pl = ((stock['pl'] ?? 0) *
                          stock['buyUnitPrice'] *
                          stock['buyQnty'] /
                          100) ??
                      0;
                  final formattedPl = pl.toStringAsFixed(2);
                  double rem = stock['remaining'];
                  double sellAmount =
                      stock['sellUnitPrice'] * stock['sellQnty'] ?? 0;
                  return DataRow(
                    cells: [
                      DataCell(Text(formattedDate)),
                      DataCell(Text('${stock['buyQnty'].toStringAsFixed(2)}')),
                      DataCell(Text('${stock['buyUnitPrice']}')),
                      DataCell(
                        Text(
                          ('${stock['buyAmount']}'),
                        ),
                      ),
                      DataCell(Text(formattedSellDate)),
                      DataCell(Text('${stock['sellQnty'].toStringAsFixed(2)}')),
                      DataCell(
                          Text(stock['sellUnitPrice']?.toString() ?? 'N/A')),
                      DataCell(Text(sellAmount.ceil().toString())),
                      DataCell(Text(formattedPl)),
                      DataCell(Text(formattedValue)),
                    ],
                    color: MaterialStateColor.resolveWith((states) =>
                        pl >= 0 ? Colors.green[300]! : Colors.red[300]!),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _showSellDialog(BuildContext context, int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Sell Item'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextFormField(
  //               controller: _sellAmountController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Sell Price',
  //               ),
  //               keyboardType:
  //                   const TextInputType.numberWithOptions(decimal: true),
  //             ),
  //             // TextFormField(
  //             //   controller: _dateController,
  //             //   readOnly: true,
  //             //   decoration: const InputDecoration(
  //             //     labelText: 'Sell Date',
  //             //   ),
  //             //   keyboardType:
  //             //       const TextInputType.numberWithOptions(decimal: true),
  //             // ),
  //             ElevatedButton(
  //               onPressed: () => _selectDate(context),
  //               child: Text(_formattedDate ?? 'Select Date'),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               // Handle OK action
  //               // final String formattedDate = DateFormat('yyyy-MM-dd')
  //               //     .format();
  //               // print(_dateController.text);
  //               _sellStock(
  //                 stocks[index]['id'],
  //                 _sellAmountController.text,
  //                 _formattedDate!,
  //               );
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showModifyDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Modify Item'),
  //         content: const Text('You selected to modify the item.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               // Handle OK action
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showDeleteDialog(BuildContext context, int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Delete Item'),
  //         content: const Text('Are you sure you want to delete this batch?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               // Handle OK action
  //               _deleteStock(stocks[index]['id']);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showCurrPriceDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Set Current Price'),
  //         content: Column(mainAxisSize: MainAxisSize.min, children: [
  //           TextFormField(
  //             controller: _currPriceController,
  //             decoration: const InputDecoration(
  //               labelText: 'Set Current Price',
  //             ),
  //             keyboardType:
  //                 const TextInputType.numberWithOptions(decimal: true),
  //           ),
  //         ]),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               // Handle OK action
  //               _setCurrentPrice(_currPriceController.text);

  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
