import 'package:flutter/material.dart';
import 'package:stock_tracker/database/multiuser_service.dart';
import 'package:stock_tracker/pages/stock_mgmt/sold.dart';
import 'package:stock_tracker/pages/stock_mgmt/stock_mgmt.dart';
// import 'package:stock_tracker/saved.dart';
// import 'database_service.dart';

class AccountScreen extends StatefulWidget {
  final String userName;
  final String userPan;
  final String stockName;

  const AccountScreen(
      {super.key,
      required this.userName,
      required this.userPan,
      required this.stockName});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _buyAmountController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> stocks = [];

  // @override
  // void initState() {
  //   super.initState();
  //    _loadStocks();
  // }

  // Future<void> _loadStocks() async {
  //   final dbStocks =
  //       await DatabaseService.instance.getAllStocks(widget.userName);
  //   setState(() {
  //     stocks = dbStocks;
  //   });
  // }

  Future<void> _addStock() async {
    if (_selectedDate != null &&
        // _nameController.text.isNotEmpty &&
        _buyPriceController.text.isNotEmpty &&
        _buyAmountController.text.isNotEmpty) {
      // _selectedDate = ;
      await DatabaseService.instance.insertStock(widget.userPan, {
        'name': widget.stockName,
        'brockerName': widget.userName,
        'buyPrice': double.parse(_buyPriceController.text),
        'buyDate': _selectedDate?.toIso8601String().split('T').first,
        'buyAmount': double.parse(_buyAmountController.text),
        'remaining': double.parse(_buyAmountController.text),
      });
      // _nameController.clear();
      _buyPriceController.clear();
      _buyAmountController.clear();
      // _selectedDate = null;
      // _loadStocks();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stockName}\'s Stocks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextFormField(
            //   controller: _nameController,
            //   decoration: const InputDecoration(
            //     labelText: 'Stock Name',
            //   ),
            // ),
            TextFormField(
              controller: _buyAmountController,
              style: const TextStyle(
                fontSize: 22,
                // color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelStyle: TextStyle(
                    // color: Colors.white,
                    ),
                labelText: 'Buy Quantity',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: _buyPriceController,
              style: const TextStyle(
                fontSize: 22,
                // color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelStyle: TextStyle(
                    // color: Colors.white,
                    ),
                labelText: 'Buy Price',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   // foregroundColor: Colors.black, // Dark violet color
              // ),
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : _selectedDate!.toLocal().toString().split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   foregroundColor: Colors.black, // Dark violet color
              // ),
              onPressed: _addStock,
              child: const Text('Add Stock'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   foregroundColor: Colors.black, // Dark violet color
              // ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return SavedStockScreen(
                    userName: widget.userName,
                    stockName: widget.stockName,
                    userPan: widget.userPan,
                  );
                }));
              },
              child: const Text("Show Holding"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   foregroundColor: Colors.black, // Dark violet color
              // ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return SoldStockScreen(
                    userName: widget.userName,
                    stockName: widget.stockName,
                    userPan: widget.userPan,
                  );
                }));
              },
              child: const Text("Show Sold"),
            ),
          ],
        ),
      ),
    );
  }
}
