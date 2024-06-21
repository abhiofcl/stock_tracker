import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './save_and_open.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

class PdfApi {
  static Future<File> generateTable(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('P/L Statment for FY- ', textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('PAN no:  ', textScaleFactor: 2),
              ],
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Name',
                  'Buy Date',
                  'Buy Price',
                  'Buy Amount',
                  'Invested Amount',
                  'Sell Date',
                  'Sell Price',
                  'Sell Qnty',
                  'Sell Amount',
                  'P/L'
                ],
                ...data.map((item) => [
                      item['name'].toString(),
                      item['buyDate'].toString(),
                      item['buyPrice'].toString(),
                      item['buyAmount'].toString(),
                      (item['buyPrice'] * item['buyAmount']).toString(),
                      item['sellDate'].toString(),
                      item['sellPrice'].toString(),
                      item['sellQnty'].toString(),
                      (item['sellPrice'] * item['sellQnty']).toString(),
                      (item['pl'] * item['buyPrice'] * item['buyAmount'] / 100)
                          .toString(),
                    ]),
              ],
            ),
          ];
        },
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }

  static Future<File> generateHoldTable(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          double totalBuyPrice = data.isNotEmpty
              ? data
                  .map((item) => (item['buyPrice']) as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          double totalQnty = data.isNotEmpty
              ? data
                  .map((item) => item['buyAmount'] as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          double totalInv = data.isNotEmpty
              ? data
                  .map((item) =>
                      (item['buyPrice'] * item['buyAmount']) as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          double totalPl = data.isNotEmpty
              ? data
                  .map((item) => (item['pl'] ?? 0.0) as double)
                  .reduce((a, b) => a + b)
              : 0.0;
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Holding Statment for FY- ', textScaleFactor: 2),
                ],
              ),
            ),
            pw.Row(
              children: <pw.Widget>[
                pw.Text('PAN no:  ', textScaleFactor: 2),
              ],
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Name',
                  'Buy Date',
                  'Buy Price',
                  'Buy Quantity',
                  'Invested Amount',
                  'Current Price',
                  'P/L'
                ],
                ...data.map(
                  (item) => [
                    item['name'].toString(),
                    item['buyDate'].toString(),
                    item['buyPrice'].toString(),
                    item['buyAmount'].toString(),
                    (item['buyPrice'] * item['buyAmount']).toString(),
                    item['currPrice'].toString(),
                    item['pl'].toString(),
                  ],
                ),
                <String>[
                  'Total',
                  '',
                  totalBuyPrice.toString(),
                  totalQnty.toString(),
                  totalInv.toString(),
                  '',
                  totalPl.toString()
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
