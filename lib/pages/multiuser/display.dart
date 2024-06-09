import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';
// import 'database_service.dart';

class AccountScreen extends StatefulWidget {
  final String userName;

  AccountScreen({required this.userName});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _buyAmountController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> stocks = [];

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    final dbStocks = await DatabaseService.instance.getStocks(widget.userName);
    setState(() {
      stocks = dbStocks;
    });
  }

  Future<void> _addStock() async {
    if (_selectedDate != null &&
        _nameController.text.isNotEmpty &&
        _buyPriceController.text.isNotEmpty &&
        _buyAmountController.text.isNotEmpty) {
      await DatabaseService.instance.insertStock(widget.userName, {
        'name': _nameController.text,
        'buyPrice': double.parse(_buyPriceController.text),
        'buyDate': _selectedDate.toString(),
        'buyAmount': double.parse(_buyAmountController.text),
      });
      _nameController.clear();
      _buyPriceController.clear();
      _buyAmountController.clear();
      _selectedDate = null;
      _loadStocks();
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
        title: Text('${widget.userName}\'s Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Stock Name',
              ),
            ),
            TextFormField(
              controller: _buyPriceController,
              decoration: InputDecoration(
                labelText: 'Buy Price',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: _buyAmountController,
              decoration: InputDecoration(
                labelText: 'Buy Amount',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : _selectedDate!.toLocal().toString().split(' ')[0]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStock,
              child: Text('Add Stock'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(stocks[index]['name']),
                    subtitle: Text(
                        'Price: ${stocks[index]['buyPrice']}, Date: ${stocks[index]['buyDate']}, Amount: ${stocks[index]['buyAmount']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
