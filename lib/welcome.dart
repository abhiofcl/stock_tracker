import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_tracker/database/database_service.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final DataBaseService _dataBaseService = DataBaseService.instance;

  late TextEditingController _dateController;

  String? _idField;
  String? _nameField;
  double? _buypriceField;
  DateTime? _buydateField;
  double? _buyamountField;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final firstDate = DateTime(DateTime.now().year - 120);
    // final lastDate = DateTime.now();

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _nameField = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Enter the stock name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _buyamountField = double.parse(value);
                  });
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: "Enter the stock quantity",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _buypriceField = double.parse(value);
                  });
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: "Enter the buying price",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Select Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _selectDate(context),
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                // print(_buydateField);
                _dataBaseService.addStock(
                    _nameField, _buyamountField, _buypriceField, _buydateField);
                _showSnackbar(context);
                setState(() {
                  _idField = null;
                  _nameField = null;
                  _buypriceField = null;
                  _buydateField = null;
                  _buyamountField = null;
                });
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
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
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _buydateField = picked;
      });
    }
  }

  void _showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('The stock for $_nameField is saved'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
