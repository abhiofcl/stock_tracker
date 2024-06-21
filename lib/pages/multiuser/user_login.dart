import 'package:flutter/material.dart';
import 'package:stock_tracker/pages/multiuser/display.dart';
import 'package:stock_tracker/pages/multiuser/multiuser_service.dart';
import 'package:stock_tracker/pages/stock_mgmt/dwd.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // List<Map<String, dynamic>> users = [];
  Map<String, List<String>> users = {};
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _idNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // final dbUsers = await DatabaseService.instance.getUsers();
    final dbUsers = await DatabaseService.instance.getUsersGroupedByPanNo();

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

// to be changed
  Future<void> _deleteUser(String userName, String userId) async {
    await DatabaseService.instance.deleteUser(userName, userId);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final panNos = users.keys.toList();
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
                              const InputDecoration(label: Text("PAN no")),
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
          Expanded(
            child: ListView.builder(
              itemCount: panNos.length,
              itemBuilder: (context, index) {
                final panNo = panNos[index];
                final brokers = users[panNo];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Download(
                              userPan: panNo,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.file_copy),
                    ),
                    title: Text(panNo),
                    children: brokers!.map((brokername) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.blue[300],
                          title: Text(brokername),
                          // subtitle: Text(users[index]['idno']),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                _deleteUser(brokername, panNo);
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
                                  userName: brokername,
                                  userPan: panNo,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
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
