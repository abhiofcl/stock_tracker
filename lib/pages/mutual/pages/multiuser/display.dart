import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/mutual/database/multiuser_service.dart';
import 'package:stock_tracker/pages/mutual/pages/stock_mgmt/sold.dart';
import 'package:stock_tracker/pages/mutual/pages/stock_mgmt/stock_mgmt.dart';
import 'package:stock_tracker/pages/mutual/saved.dart';
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
  final TextEditingController _unitPriceController = TextEditingController();
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
      final qnty = (double.parse(_buyAmountController.text) /
          double.parse(_buyPriceController.text));
      await DatabaseService.instance.insertStock(widget.userPan, {
        'name': widget.stockName,
        'folioNo': widget.userName,
        'buyDate': _selectedDate?.toIso8601String().split('T').first,
        'buyAmount': double.parse(_buyAmountController.text),
        'buyUnitPrice': double.parse(_buyPriceController.text),
        'buyQnty': qnty,
        'remaining': double.parse(_buyAmountController.text),
      });
      // _nameController.clear();
      _buyPriceController.clear();
      _buyAmountController.clear();
      _selectedDate = null;
      // _loadStocks();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
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
  void dispose() {
    _buyAmountController.dispose();
    _buyPriceController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stockName}\'s Funds'),
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
              // style: TextStyle(color: Colors.white, fontSize: 22),
              controller: _buyAmountController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(
                    // color: Colors.white,
                    ),
                labelText: 'Buy Amount',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              // style: TextStyle(color: Colors.white, fontSize: 22),
              controller: _buyPriceController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(
                    // color: Colors.white,
                    ),
                labelText: 'Buy Unit Price',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : _selectedDate!.toLocal().toString().split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStock,
              child: const Text('Add Batch'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
