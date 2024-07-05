import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stock_tracker/choose.dart';
import 'package:stock_tracker/pages/multiuser/user_login.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  runApp(const MainApp());
}

const Color ivory = Color(0xFFFFF8E1);
const Color navyBlue = Color(0xFF001F3F);
const Color darkGreen = Color(0xFF006400);
const Color deepPurple = Color(0xFF4B0082);
const Color crimsonRed = Color(0xFFDC143C);
const Color darkSlateGray = Color(0xFF2F4F4F);
const Color chocolate = Color(0xFFD2691E);
const Color teal = Color(0xFF008080);
const Color darkOrange = Color(0xFFFF8C00);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: ivory,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.bold, color: navyBlue),
          displayMedium: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: darkGreen),
          bodyLarge: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.normal,
              color: darkSlateGray),
          bodyMedium: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.normal, color: teal),
          // Add other text styles as needed
        ),
        // appBarTheme: const AppBarTheme(
        //   color: deepPurple,
        // ),
        buttonTheme: const ButtonThemeData(
          buttonColor: crimsonRed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkOrange,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF008080), // White text
            textStyle:
                const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      // darkTheme: ThemeData.dark(useMaterial3: true),
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  MyWidget({super.key});
  final TextEditingController _usernameLoginController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _checkLogin(BuildContext context) {
    String username = _usernameLoginController.text;
    String password = _passwordController.text;
    if (username == 'prasadrajanmenon' && password == 'Prm@2024S') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Choose()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
    _passwordController.clear();
    _usernameLoginController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Text(
          "Stock Tracker",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameLoginController,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                // color: Colors.white,
              ),
              decoration: const InputDecoration(
                  labelStyle: TextStyle(
                      // fontWeight: FontWeight.bold,
                      // color: Colors.white,
                      ),
                  label: Text("Username")),
            ),
            TextFormField(
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                // color: Colors.white,
                fontSize: 22,
              ),
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelStyle: TextStyle(
                      // fontWeight: FontWeight.bold,
                      // color: Colors.white,
                      ),
                  label: Text("Password")),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                // style: Theme.of(context).elevatedButtonTheme,
                onPressed: () => _checkLogin(context),
                child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
