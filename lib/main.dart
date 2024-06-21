import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/user_login.dart';
import 'package:stock_tracker/pages/statement_dwd/pdf_service.dart';
import 'package:stock_tracker/pages/statement_dwd/save_and_open.dart';
import 'package:stock_tracker/pages/stock_mgmt/dwd.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color.fromARGB(255, 107, 140, 156),
      ),
      // darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text(
          "Stock Tracker",
          style: TextStyle(color: Colors.amber),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       // final tablePdf = await PdfApi.generateTable();
        //       // SaveAndOpenDocument.openPdf(tablePdf);
        //       Navigator.of(context)
        //           .push(MaterialPageRoute(builder: (context) => Download()));
        //     },
        //     icon: const Icon(Icons.edit_document),
        //   ),
        // ],
      ),
      body: const LoginScreen(),
    );
  }
}
