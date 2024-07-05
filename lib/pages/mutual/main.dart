// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:mutual_funds/pages/login.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// // import 'package:mutual_funds/pages/multiuser/user_login.dart';
// Future main() async {
//   if (Platform.isWindows || Platform.isLinux) {
//     sqfliteFfiInit();
//   }
//   databaseFactory = databaseFactoryFfi;
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: const Color.fromARGB(255, 107, 140, 156),
//       ),
//       // darkTheme: ThemeData.dark(useMaterial3: true),
//       home: const MyWidget(),
//     );
//   }
// }

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.black26,
//           title: const Text(
//             "Mutual Funds",
//             style: TextStyle(color: Colors.amber),
//           ),
//         ),
//         body: const LoginScreen());
//   }
// }


// // class MyWidget extends StatelessWidget {
// //   MyWidget({super.key});
// //   final TextEditingController _usernameLoginController =
// //       TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   void _checkLogin(BuildContext context) {
// //     String username = _usernameLoginController.text;
// //     String password = _passwordController.text;
// //     if (username == 'prasadrajanmenon' && password == 'Prm@2024S') {
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (context) => const LoginScreen()));
// //     } else {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
// //     }
// //     _passwordController.clear();
// //     _usernameLoginController.clear();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.black26,
// //         title: const Text(
// //           "Stock Tracker",
// //           style: TextStyle(color: Colors.amber),
// //         ),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             TextFormField(
// //               controller: _usernameLoginController,
// //               decoration: const InputDecoration(label: Text("Username")),
// //             ),
// //             TextFormField(
// //               controller: _passwordController,
// //               decoration: const InputDecoration(label: Text("Password")),
// //               obscureText: true,
// //             ),
// //             const SizedBox(
// //               height: 10,
// //             ),
// //             ElevatedButton(
// //                 onPressed: () => _checkLogin(context),
// //                 child: const Text("Login")),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
