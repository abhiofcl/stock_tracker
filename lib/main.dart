import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stock_tracker/pages/banking/banking_main.dart';
import 'package:stock_tracker/pages/multiuser/user_login.dart';
// import 'package:stock_tracker/pages/statement_dwd/pdf_service.dart';
// import 'package:stock_tracker/pages/statement_dwd/save_and_open.dart';
// import 'package:stock_tracker/pages/stock_mgmt/dwd.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 107, 140, 156),
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
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Pick your choice"),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return LoginScreen();
                }));
              },
              title: const Text("Stocks"),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return BankingMainScreen();
                }));
              },
              title: Text("Banking"),
            ),
          ],
        ),
      ),
      body: const LoginScreen(),
    );
  }
}
