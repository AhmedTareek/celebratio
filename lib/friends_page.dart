import 'package:celebratio/CustomWidget.dart';
import 'package:celebratio/Model/fb_Friend.dart';
import 'package:celebratio/Model/local_db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Model/friend.dart';
import 'app_state.dart';
import 'events_page.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController _searchController = TextEditingController();
  List<FbFriend> allFriends = []; // Example data
  List<FbFriend> filteredFriends = [];

  _filterFriends() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = allFriends
          .where((friend) => friend.name.toLowerCase().contains(query))
          .toList();
    });
  }

  _fetchFriends() async {
    var appState = Provider.of<ApplicationState>(context, listen: false);
    try {
      var temp = await appState.getFriends();
      setState(() {
        allFriends = temp.toList();
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
                    var appState =
                        Provider.of<ApplicationState>(context, listen: false);
                    appState.addFriend(email: emailController.text);
                  } catch (e) {
                    print(e);
                    // Show error message if database operation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error adding user: ${e.toString()}')),
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
        newButton: NewButton(
            label: 'New Friend',
            onPressed: () {
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
            // trailing: FutureBuilder<String>(
            //   future: _getUpcomingEventsCount(filteredFriends[index].id!),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const SizedBox(); // Loading
            //     } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            //       return const SizedBox(); // No notification
            //     } else {
            //       if(snapshot.data == '0') {
            //         return const SizedBox(); // No notification
            //       }
            //       return Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           CircleAvatar(
            //             radius: 15,
            //             backgroundColor: Theme.of(context).secondaryHeaderColor,
            //           ),
            //           Positioned(
            //             child: Text(
            //               snapshot.data.toString(), // Notification number
            //               style: const TextStyle(
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     }
            //   },
            // ),
            onTap: () {
              // navigate to events page with friend's id
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsPage(
                    userUid: filteredFriends[index].id,
                    userDisplayName: filteredFriends[index].name,
                  ), // to be handled in events_page.dart
                ),
              );
            },
          );
        },
        itemCount: filteredFriends.length);
  }

  Future<String> _getUpcomingEventsCount(int userId) async {
    // try {
    //   var count = await db.getUpcomingEventsCountByUserId(userId);
    //   return count.toString();
    // } catch (e) {
    //   return '';
    // }

    return '';
  }
}
