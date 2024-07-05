import 'package:flutter/material.dart';
// import 'package:stock_tracker/pages/multiuser/display.dart';
import 'package:stock_tracker/database/multiuser_service.dart';
// import 'package:stock_tracker/pages/mutual/mutual_saved.dart';
import 'package:stock_tracker/pages/stock_mgmt/dwd.dart';
import 'package:stock_tracker/saved.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, List<String>> users = {};
  // Map<String, List<String>> mFUSers = {};
  // int flag = 1;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _idNoController = TextEditingController();
  final ScrollController controller = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dbUsers = await DatabaseService.instance.getUsersGroupedByPanNo();
    // final mfUsers = await DatabaseService.instance.getMfUsersGroupedByPanNo();
    setState(() {
      users = dbUsers;
      // mFUSers = mfUsers;
    });
  }

  Future<void> _addUser(String userName, String userId) async {
    await DatabaseService.instance.addUser(userName, userId);

    _userNameController.clear();
    _idNoController.clear();
    _loadUsers();
  }

  Future<void> _deleteUser(String userName, String userId) async {
    await DatabaseService.instance.deleteUser(userName, userId);
    _loadUsers();
  }

  Future<void> _deletepan(String userId) async {
    await DatabaseService.instance.deletePAN(userId);
    _loadUsers();
  }

  Future<void> _deleteDB() async {
    await DatabaseService.instance.deleteDatabaseFile();
    _loadUsers();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _idNoController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panNos = {
      ...users.keys,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        foregroundColor: Colors.white,
        title: const Text('Select Account'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete the entire database?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          // Handle OK action
                          _deleteDB();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                          controller: _userNameController,
                          onChanged: (value) {
                            setState(() {
                              _userNameController.text = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              label: Text("Client id")),
                        ),
                        TextFormField(
                          controller: _idNoController,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _idNoController.text = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              label: Text("PAN no")),
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
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _addUser(_userNameController.text,
                                      _idNoController.text);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
            child: RawScrollbar(
              controller: controller,
              thickness: 10,
              thumbColor: Colors.white,
              child: ListView.builder(
                controller: controller,
                itemCount: panNos.length,
                itemBuilder: (context, index) {
                  final panNo = panNos[index];
                  final brokers = users[panNo] ?? [];
                  // final schemes = mFUSers[panNo] ?? [];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedBackgroundColor: Colors.blue,
                      // backgroundColor: Colors.blue,
                      leading: IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete the PAN?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      // Handle OK action
                                      _deletepan(panNo);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      title: Text(
                        panNo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      children: brokers.map((brokername) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Download(
                                      userPan: panNo,
                                      brockerName: brokername,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_document),
                            ),
                            tileColor: Colors.amber[300],
                            title: Text(
                              brokername,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                                  _deleteUser(
                                                      brokername, panNo);
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
                                  builder: (context) => Saved(
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
          ),
        ],
      ),
    );
  }
}
