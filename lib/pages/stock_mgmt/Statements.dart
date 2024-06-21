import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';
import 'package:stock_tracker/pages/statement_dwd/pdf_service.dart';
import 'package:stock_tracker/pages/statement_dwd/save_and_open.dart';

class Statement extends StatefulWidget {
  final String userName;
  final String userPan;
  final String stockName;
  const Statement(
      {super.key,
      required this.userName,
      required this.userPan,
      required this.stockName});

  @override
  State<Statement> createState() => _StatementState();
}

class _StatementState extends State<Statement> {
  List<Map<String, dynamic>> plStocks = [];
  List<Map<String, dynamic>> holdStocks = [];
  List<Map<String, dynamic>> stocksData = [];
  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    final dbStocks = await DatabaseService.instance
        .getPLStocks(widget.userPan, widget.stockName);
    final dbHStocks = await DatabaseService.instance
        .getHoldingStocks(widget.userPan, widget.stockName);

    setState(() {
      plStocks = dbStocks;
      holdStocks = dbHStocks;
      // stocksData = data;
    });
  }

  Future<void> _loadSFYST(int id) async {
    // print(widget.userPan);
    if (id == 1) {
      final data = await DatabaseService.instance
          .fetchFinancialYearDataPL(widget.userPan, '2023');
      setState(() {
        stocksData = data;
      });
    } else if (id == 2) {
      // final now = DateTime.now();
      // now = now.toIso8601String();
      final data = await DatabaseService.instance
          .fetchFinancialYearDataHold(widget.userPan, '2023');
      setState(() {
        stocksData = data;
      });
    }
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
                await _loadSFYST(1);
                final tablePdf = await PdfApi.generateTable(stocksData);
                SaveAndOpenDocument.openPdf(tablePdf);
              },
              icon: const Icon(Icons.save),
            ),
            IconButton(
              onPressed: () async {
                await _loadSFYST(2);
                final tablePdf = await PdfApi.generateHoldTable(stocksData);
                SaveAndOpenDocument.openPdf(tablePdf);
              },
              icon: const Icon(Icons.grade),
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
            pLState(),
            holdState(),
          ],
        ),
      ),
    );
  }

  Widget pLState() {
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

  Widget holdState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: holdStocks.length,
            itemBuilder: (context, index) {
              final String formattedDate = DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(holdStocks[index]['buyDate']));
              double value = holdStocks[index]['pl'] ?? 0;
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
