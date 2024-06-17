import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/display.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<Map<String, dynamic>> users = [];
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _idNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dbUsers = await DatabaseService.instance.getUsers();
    setState(() {
      users = dbUsers;
    });
  }

  Future<void> _addUser(String userName, String userId) async {
    await DatabaseService.instance.addUser(userName, userId);
    _userNameController.clear();
    _idNoController.clear();
    _loadUsers();
  }

  Future<void> _deleteUser(String userName) async {
    await DatabaseService.instance.deleteUser(userName);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        foregroundColor: Colors.white,
        title: const Text('Select Account'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userNameController,
                          onChanged: (value) {
                            setState(() {
                              _userNameController.text = value;
                            });
                          },
                          decoration:
                              const InputDecoration(label: Text("name")),
                        ),
                        TextFormField(
                          controller: _idNoController,
                          onChanged: (value) {
                            setState(() {
                              _idNoController.text = value;
                            });
                          },
                          decoration:
                              const InputDecoration(label: Text("id no")),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _addUser(_userNameController.text,
                                      _idNoController.text);
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: _userNameController,
          //     decoration: InputDecoration(
          //       labelText: 'Add New Account',
          //       suffixIcon: IconButton(
          //         icon: Icon(Icons.add),
          //         onPressed: () {
          //           if (_userNameController.text.isNotEmpty) {
          //             _addUser(_userNameController.text, _idNoController.text);
          //           }
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    iconColor: Colors.red,
                    leading: const Icon(Icons.person),
                    contentPadding: const EdgeInsets.all(8),
                    tileColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(users[index]['name']),
                    subtitle: Text(users[index]['idno']),
                    onLongPress: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Delete this user??"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _deleteUser(users[index]['name']);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Delete"),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(
                            userName: users[index]['name'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class AccountScreen extends StatelessWidget {
//   final String userName;

//   AccountScreen({required this.userName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$userName\'s Account'),
//       ),
//       body: Center(
//         child: Text('Welcome to $userName\'s account!'),
//       ),
//     );
//   }
// }
