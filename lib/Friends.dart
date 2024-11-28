import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/local_db.dart';
import 'package:flutter/material.dart';

import 'Model/user.dart';

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
        newButton: NewButton(label: 'New Friend', onPressed: () {}),
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
          );
        },
        itemCount: filteredFriends.length);
  }
}
