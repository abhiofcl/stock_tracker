import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/user_login.dart';
import 'package:stock_tracker/saved.dart';
import 'package:stock_tracker/welcome.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // darkTheme: ThemeData.dark(useMaterial3: true),
      home: MyWidget(),
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
        title: const Text("Stock Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const Saved();
              }));
            },
          ),
        ],
      ),
      body: LoginScreen(),
    );
  }
}
