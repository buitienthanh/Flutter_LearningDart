// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'db_handler.dart';
import 'views/bottom_navigation.dart';

enum MenuAction { logout }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHandler.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  // if id != null then will allow update data

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _titleController.text = "";
                  _descController.text = "";

                  // Hide bottom sheet
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addData() async {
    await SQLHandler.createData(_titleController.text, _descController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color.fromARGB(255, 97, 82, 255),
      content: Text("Data added."),
    ));
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHandler.updateData(
        id, _titleController.text, _descController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color.fromARGB(255, 97, 82, 255),
      content: Text("Data updated."),
    ));
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    await SQLHandler.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data delete success."),
    ));
    _refreshData();
  }

  
  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("????ng xu???t"),
            content: const Text("B???n c?? ch???c mu???n tho??t ????ng xu???t?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("????ng xu???t")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("H???y b???")),
            ],
          );
        }).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavagation(tabKey: 0),
      backgroundColor: Color.fromARGB(255, 225, 222, 235),
      appBar: AppBar(
        title: Text(
          "CURD Operations Demotrations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<MenuAction>(
            color: Colors.white,
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login/',
                      (route) => false,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("????ng xu???t"),
                )
              ];
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        _allData[index]['title'],
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      _allData[index]['desc'],
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 30.0,
                          onPressed: () {
                            showBottomSheet(_allData[index]['id']);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                        ),
                        IconButton(
                          iconSize: 30.0,
                          onPressed: () {
                            _deleteData(_allData[index]['id']);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => showBottomSheet(null),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
