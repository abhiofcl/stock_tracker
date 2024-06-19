import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';
import 'package:stock_tracker/pages/statement_dwd/pdf_service.dart';
import 'package:stock_tracker/pages/statement_dwd/save_and_open.dart';

class Statement extends StatefulWidget {
  final String userName;
  final String stockName;
  const Statement({super.key, required this.userName, required this.stockName});

  @override
  State<Statement> createState() => _StatementState();
}

class _StatementState extends State<Statement> {
  List<Map<String, dynamic>> plStocks = [];
  List<Map<String, dynamic>> holdStocks = [];
  List<Map<String, dynamic>> stocksData = [];
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    final dbStocks = await DatabaseService.instance
        .getPLStocks(widget.userName, widget.stockName);
    final dbHStocks = await DatabaseService.instance
        .getHoldingStocks(widget.userName, widget.stockName);
    final data = await DatabaseService.instance
        .fetchFinancialYearData(widget.userName, '2023');
    // final buya = await DatabaseService.instance
    //     .getBuyAvg(widget.userName, widget.stockName);
    // final totalInv = await DatabaseService.instance
    //     .getTotalStockOverview(widget.userName, widget.stockName);

    setState(() {
      plStocks = dbStocks;
      holdStocks = dbHStocks;
      stocksData = data;
    });
  }

  Future<void> _loadSFYST() async {
    final data = await DatabaseService.instance
        .fetchFinancialYearData(widget.userName, '2023');
    // final buya = await DatabaseService.instance
    //     .getBuyAvg(widget.userName, widget.stockName);
    // final totalInv = await DatabaseService.instance
    //     .getTotalStockOverview(widget.userName, widget.stockName);

    setState(() {
      stocksData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statement Page"),
          actions: [
            IconButton(
              onPressed: () async {
                _loadSFYST();
                final tablePdf = await PdfApi.generateTable(stocksData);
                SaveAndOpenDocument.openPdf(tablePdf);
              },
              icon: const Icon(Icons.save),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "P/L",
                icon: Icon(Icons.auto_graph),
              ),
              Tab(
                text: "Holdings",
                icon: Icon(Icons.save),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PLState(),
            HoldState(),
          ],
        ),
      ),
    );
  }

  Widget PLState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: plStocks.length,
            itemBuilder: (context, index) {
              final String formattedDate = DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(plStocks[index]['buyDate']));
              double value = plStocks[index]['pl'];
              final formattedValue = value.toStringAsFixed(2);
              return Card(
                child: ListTile(
                  leading: Text('${plStocks[index]['buyAmount']}'),
                  title: Text(
                      '$formattedDate - Rs.${plStocks[index]['buyPrice']}  $formattedValue%'),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget HoldState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: holdStocks.length,
            itemBuilder: (context, index) {
              final String formattedDate = DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(holdStocks[index]['buyDate']));
              double value = holdStocks[index]['pl'];
              final formattedValue = value.toStringAsFixed(2);
              return Card(
                child: ListTile(
                  leading: Text('${holdStocks[index]['buyAmount']}'),
                  title: Text(
                      '$formattedDate - Rs.${holdStocks[index]['buyPrice']}  $formattedValue%'),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
