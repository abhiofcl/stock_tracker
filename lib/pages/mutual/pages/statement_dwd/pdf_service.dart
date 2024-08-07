import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './save_and_open.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

class PdfApi {
  static Future<File> generateTable(String panNo, String brokerName, int fyYear,
      List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        // orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          double totalPl = data.isNotEmpty
              ? data
                  .map((item) => ((item['pl'] ?? 0) *
                          item['buyUnitPrice'] *
                          item['buyQnty'] /
                          100 ??
                      0.0) as double)
                  .reduce((a, b) => a + b)
                  .ceil()
                  .toDouble()
              : 0.0;
          double totalUnits = data.isNotEmpty
              ? data.map((item) => item['buyQnty']).reduce((a, b) => a + b)
              : 0.0;
          double totalInv = data.isNotEmpty
              ? data
                  .map((item) =>
                      (item['buyUnitPrice'] * item['buyQnty']) as double)
                  .reduce((a, b) => a + b)
                  .ceil()
                  .toDouble()
              : 0.0;

          double totalPv = data.isNotEmpty
              ? data
                  .map((item) => ((item['sellUnitPrice'] ?? 0) *
                      item['buyQnty']) as double)
                  .reduce((a, b) => a + b)
                  .ceil()
                  .toDouble()
              : 0.0;
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('P/L Statment for FY: ${fyYear - 1} - $fyYear ',
                      textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('PAN no:  $panNo', textScaleFactor: 2),
              ],
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('Client id/Name:  $brokerName', textScaleFactor: 1),
              ],
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Name',
                  'Buy Date',
                  'Units',
                  'Unit Price',
                  'Amount',
                  'Sell Date',
                  'Sell Units',
                  'Sell unit Price',
                  'Sell Amnt',
                  'Profit / Loss'
                ],
                ...data.map(
                  (item) => [
                    item['name'].toString(),
                    (DateFormat('dd-MM-yy')
                            .format(DateTime.parse(item['buyDate'])))
                        .toString(),
                    item['buyQnty'].ceil().toString(),
                    item['buyUnitPrice'].toString(),
                    (item['buyUnitPrice'] * item['buyQnty']).ceil().toString(),
                    (DateFormat('dd-MM-yy')
                            .format(DateTime.parse(item['sellDate'])))
                        .toString(),
                    item['sellQnty'].ceil().toString(),
                    item['sellUnitPrice'].ceil().toString(),
                    (item['sellUnitPrice'] * item['sellQnty'])
                        .ceil()
                        .toString(),
                    ((((item['sellUnitPrice'] * item['sellQnty']) -
                            (item['buyUnitPrice'] * item['buyQnty']))))
                        .ceil()
                        .toString(),
                  ],
                ),
                <String>[
                  'Total',
                  '',
                  totalUnits.toStringAsFixed(2),
                  '',
                  totalInv.ceil().toString(),
                  '',
                  '',
                  '',
                  totalPv.ceil().toString(),
                  totalPl.ceil().toString(),
                ],
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }

  static Future<File> generateHoldTable(String panNo, String brokerName,
      int fyYear, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    // int days=0;
    pdf.addPage(
      pw.MultiPage(
        // orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          // double totalBuyPrice = data.isNotEmpty
          //     ? data
          //         .map((item) => (item['buyPrice']) as double)
          //         .reduce((a, b) => a + b)
          //     : 0.0;
          // double totalQnty = data.isNotEmpty
          //     ? data
          //         .map((item) => item['buyAmount'] as double)
          //         .reduce((a, b) => a + b)
          //     : 0.0;
          double totalPl = data.isNotEmpty
              ? data
                  .map((item) => ((item['pl'] ?? 0) *
                          item['buyUnitPrice'] *
                          item['buyQnty'] /
                          100 ??
                      0.0) as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          double totalInv = data.isNotEmpty
              ? data
                  .map((item) => (item['buyAmount']) as double)
                  .reduce((a, b) => a + b)
              : 0.0;

          double totalPv = data.isNotEmpty
              ? data
                  .map((item) =>
                      ((item['currPrice'] ?? 0) * item['buyQnty']) as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          DateTime today = DateTime.now();
          String end = '$fyYear-03-31';
          // int totalDays = data.isNotEmpty
          // ? data.map((item) {
          //         String buyDateStr = item['buyDate'];
          //         DateTime buyDate = DateTime.parse(buyDateStr);
          //         return today.difference(buyDate).inDays;
          //       })
          //     : 0;
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Holding Statment for FY: ${fyYear - 1} - $fyYear',
                      textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('PAN no:  $panNo', textScaleFactor: 2),
              ],
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('Client id/Name:  $brokerName', textScaleFactor: 1),
              ],
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Name',
                  'Buy Date',
                  'Units',
                  'Unit Price',
                  'Inv Amnt',
                  'Pr Unit Value',
                  'Present Value',
                  'Profit / Loss',
                  'Holding days',
                ],
                ...data.map(
                  (item) => [
                    item['name'].toString(),
                    (DateFormat('dd-MM-yy')
                            .format(DateTime.parse(item['buyDate'])))
                        .toString(),
                    item['buyQnty'].ceil().toString(),
                    item['buyUnitPrice'].toStringAsFixed(2),
                    (item['buyAmount']).ceil().toString(),
                    (item['currPrice'] ?? 0).ceil().toString(),
                    ((item['currPrice'] ?? 0) * item['buyQnty'])
                        .ceil()
                        .toString(),
                    ((item['pl'] ?? 0) *
                            item['buyUnitPrice'] *
                            item['buyQnty'] /
                            100)
                        .ceil()
                        .toString(),
                    (DateTime.parse(end)
                            .difference(DateTime.parse(item['buyDate']))
                            .inDays)
                        .toString(),
                  ],
                ),
                <String>[
                  'Total',
                  '',
                  '',
                  '',
                  totalInv.ceil().toString(),
                  '',
                  totalPv.ceil().toString(),
                  totalPl.ceil().toString(),
                ],
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }
}
