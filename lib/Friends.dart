import 'package:celebratio/CustomWidget.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allFriends = ["Alice", "Bob", "Charlie", "David"]; // Example data
  List<String> filteredFriends = [];

  void _filterFriends() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = allFriends
          .where((friend) => friend.toLowerCase().contains(query))
          .toList();
    });
  }


  @override
  void initState() {
    super.initState();
    filteredFriends = allFriends; // Initially display all friends
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
      newButton: NewButton(label: 'New Friend',onPressed: (){}),
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
            title: Text(filteredFriends[index]),
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


