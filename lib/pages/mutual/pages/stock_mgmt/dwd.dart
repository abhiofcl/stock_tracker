import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/mutual/database/multiuser_service.dart';
import 'package:stock_tracker/pages/mutual/pages/statement_dwd/pdf_service.dart';
import 'package:stock_tracker/pages/mutual/pages/statement_dwd/save_and_open.dart';

class Download extends StatefulWidget {
  final String userPan;
  final String brockerName;
  const Download({super.key, required this.userPan, required this.brockerName});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  List<Map<String, dynamic>> stocksData = [];
  List<Map<String, dynamic>> years = [];
  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    final yearList = await DatabaseService.instance.getFY(widget.userPan);
    setState(() {
      years = yearList;
    });
  }

  // Future<void> _loadSFYST(int id) async {
  // // print(widget.userPan);
  //   if (id == 1) {
  //     final data = await DatabaseService.instance
  //         .fetchFinancialYearDataPL(widget.userPan, '2024');
  //     setState(() {
  //       stocksData = data;
  //     });
  //   } else if (id == 2) {
  //     // final now = DateTime.now();
  //     // now = now.toIso8601String();
  //     final data = await DatabaseService.instance
  //         .fetchFinancialYearDataHold(widget.userPan, '2024');
  //     setState(() {
  //       stocksData = data;
  //     });
  //   }
  // }

  Future<void> _loadYearWise(int id, int year) async {
    // print(widget.userPan);
    if (id == 1) {
      final data = await DatabaseService.instance.fetchFinancialYearWiseDataPL(
          widget.userPan, widget.brockerName, year);
      setState(() {
        stocksData = data;
      });
    } else if (id == 2) {
      // final now = DateTime.now();
      // now = now.toIso8601String();
      final data = await DatabaseService.instance
          .fetchFinancialYearWiseDataHold(
              widget.userPan, widget.brockerName, year);
      setState(() {
        stocksData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statement for ${widget.userPan}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        backgroundColor: const Color.fromARGB(96, 198, 173, 51),
                        collapsedBackgroundColor:
                            const Color.fromARGB(96, 198, 173, 51),
                        title: Text(
                          '${int.parse(years[index]['fy']) - 1} - ${years[index]['fy']}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.amber,
                              title: const Text("P/L"),
                              onTap: () async {
                                await _loadYearWise(
                                  1,
                                  int.parse(years[index]['fy']),
                                );
                                final tablePdf = await PdfApi.generateTable(
                                    widget.userPan,
                                    widget.brockerName,
                                    int.parse(years[index]['fy']),
                                    stocksData);
                                SaveAndOpenDocument.openPdf(tablePdf);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.amber,
                              title: const Text("Holding"),
                              onTap: () async {
                                await _loadYearWise(
                                  2,
                                  int.parse(years[index]['fy']),
                                );
                                final tablePdf = await PdfApi.generateHoldTable(
                                    widget.userPan,
                                    widget.brockerName,
                                    int.parse(years[index]['fy']),
                                    stocksData);
                                SaveAndOpenDocument.openPdf(tablePdf);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
