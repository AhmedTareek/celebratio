import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/local_db.dart';
import 'package:flutter/material.dart';

import 'Model/user.dart';
import 'events_page.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final db = DataBase();
  final TextEditingController _searchController = TextEditingController();
  List<User> allFriends = []; // Example data
  List<User> filteredFriends = [];

  _filterFriends() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = allFriends
          .where((friend) => friend.name.toLowerCase().contains(query))
          .toList();
    });
  }

  _fetchFriends() async {
    try {
      var temp = await db.getAllUsers();
      setState(() {
        allFriends = List<User>.from(temp);
        _filterFriends();
      });
    } catch (e) {
      // print('Error fetching friends: $e');
    }
  }

  void _addNewUser() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Friend'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without adding
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  try {
                    // Create user object
                    User user = User(name: nameController.text, email: emailController.text);
                    // Insert user into the database
                    final response = await db.insertNewUser(user);
                    user.id = response;
                    if (response > 0) {
                      setState(() {
                        allFriends.add(user);
                        _filterFriends();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User added successfully')),
                        );
                      });
                      Navigator.pop(context); // Close the dialog
                    } else {
                      throw Exception('Failed to insert user');
                    }
                  } catch (e) {
                    print(e);
                    // Show error message if database operation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding user: ${e.toString()}')),
                    );
                  }
                } else {
                  // Show error message if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchFriends();
    filteredFriends = allFriends;
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomWidget(
        title: 'My Friends',
        newButton: NewButton(label: 'New Friend', onPressed: () {
          _addNewUser();
        }),
        topWidget: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: const InputDecoration(
              label: Text('search'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        filterButtons: [],
        sortOptions: [],
        tileBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(),
            title: Text(filteredFriends[index].name),
            subtitle: const Text('Hello, I am using Celebratio'),
            trailing: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
                Positioned(
                  child: Text(
                    '3', // Notification number
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: (){
              // navigate to events page with friend's id
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsPage(userId: filteredFriends[index].id),
                ),
              );
            },
          );
        },
        itemCount: filteredFriends.length);
  }
}
