import 'package:flutter/material.dart';
import 'package:stock_tracker/database/multiuser_service.dart';
import 'package:stock_tracker/pages/mutual/mutual_mgmt.dart';
import 'package:stock_tracker/pages/stock_mgmt/sold.dart';
import 'package:stock_tracker/pages/stock_mgmt/stock_mgmt.dart';
import 'package:stock_tracker/saved.dart';
// import 'database_service.dart';

class MutualAddScreen extends StatefulWidget {
  final String userName;
  final String userPan;
  final String stockName;

  const MutualAddScreen(
      {super.key,
      required this.userName,
      required this.userPan,
      required this.stockName});

  @override
  _MutualAddScreenState createState() => _MutualAddScreenState();
}

class _MutualAddScreenState extends State<MutualAddScreen> {
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
        'schemeName': widget.userName,
        'buyPrice': double.parse(_buyPriceController.text),
        'buyDate': _selectedDate?.toIso8601String().split('T').first,
        'buyUnits': double.parse(_buyAmountController.text),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stockName}'),
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
              decoration: const InputDecoration(
                labelText: 'Units',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: _buyPriceController,
              decoration: const InputDecoration(
                labelText: 'Buy Price',
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
              child: const Text('Add'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return SavedMutualScreen(
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
