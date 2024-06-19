import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
                  pw.Text('Geeksforgeeks', textScaleFactor: 2),
                ],
              ),
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'Name',
                  'Buy Price',
                  'Buy Amount',
                  'Buy Date',
                  'Current Price',
                  'P/L'
                ],
                ...data.map((item) => [
                      item['name'].toString(),
                      item['buyPrice'].toString(),
                      item['buyAmount'].toString(),
                      item['buyDate'].toString(),
                      item['currPrice'].toString(),
                      item['pl'].toString(),
                    ]),
              ],
            ),
          ];
        },
      ),
    );
    return SaveAndOpenDocument.savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }
}
