import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/display.dart';
import 'package:stock_tracker/database/multiuser_service.dart';
import 'package:stock_tracker/pages/mutual/mutual_display.dart';
import 'package:stock_tracker/pages/stock_mgmt/stock_mgmt.dart';

class MutualSaved extends StatefulWidget {
  final String userName;
  final String userPan;
  const MutualSaved({super.key, required this.userName, required this.userPan});

  @override
  State<MutualSaved> createState() => _MutualSavedState();
}

class _MutualSavedState extends State<MutualSaved> {
  TextEditingController _stockNameController = TextEditingController();
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> _foundStocks = [];
  int totalQuant = 0;

  @override
  void initState() {
    _loadStocks();
    _foundStocks = stocks;
    super.initState();
  }

  Future<void> _loadStocks() async {
    final dbStocks = await DatabaseService.instance
        .getStockName(widget.userName, widget.userPan);
    setState(() {
      stocks = dbStocks;
      _foundStocks = dbStocks;
    });
  }

  Future<void> _addStock(String stockname) async {
    await DatabaseService.instance
        .addStockname(widget.userName, widget.userPan, stockname);
    _stockNameController.clear();
    _loadStocks();
  }

  Future<void> _deleteStock(String id) async {
    await DatabaseService.instance
        .deleteStockName(widget.userPan, id, widget.userName);
    _loadStocks();
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = stocks;
    } else {
      results = stocks
          .where((user) => user['stockName']
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundStocks = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Mutual Fund"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _stockNameController,
                          onChanged: (value) {
                            setState(() {
                              _stockNameController.text = value;
                            });
                          },
                          decoration: const InputDecoration(
                              label: Text("Company name")),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _addStock(_stockNameController.text);
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
      body: stocks.isEmpty
          ? const Center(
              child: Text(
                "No stocks",
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged: (value) => _runFilter(value),
                    decoration: const InputDecoration(
                        labelText: "Search", suffixIcon: Icon(Icons.search)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _foundStocks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.blue[300],
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(_foundStocks[index]['stockName']),
                            trailing: PopupMenuButton(
                              onSelected: (String result) {
                                switch (result) {
                                  case 'Delete':
                                    _showDeleteDialog(context, index);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return MutualAddScreen(
                                    userName: widget.userName,
                                    stockName: stocks[index]['stockName'],
                                    userPan: widget.userPan,
                                  );
                                }),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                _deleteStock(stocks[index]['stockName']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
