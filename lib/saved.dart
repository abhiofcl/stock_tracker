import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';
import 'package:stock_tracker/pages/stock_mgmt/stock_mgmt.dart';

class Saved extends StatefulWidget {
  final String userName;
  final String userPan;
  const Saved({super.key, required this.userName, required this.userPan});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<Map<String, dynamic>> stocks = [];
  int totalQuant = 0;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    final dbStocks = await DatabaseService.instance
        .getTotalQuantity(widget.userName, widget.userPan);
    setState(() {
      stocks = dbStocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Stocks"),
      ),
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(stocks[index]['name']),
              // subtitle: Text(
              //   'Price: ${stocks[index]['buyPrice']}, Date: ${stocks[index]['buyDate']}, Amount: ${stocks[index]['buyAmount']}',
              // ),
              trailing: Text('${stocks[index]['total_quantity']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SavedStockScreen(
                      userName: widget.userName,
                      stockName: stocks[index]['name'],
                      userPan: widget.userPan,
                    );
                  }),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
