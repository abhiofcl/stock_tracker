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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 40, 60, 69),
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
      body: LoginScreen(),
    );
  }
}
