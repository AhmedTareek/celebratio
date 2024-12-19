import 'package:flutter/material.dart';
import 'package:celebratio/smart_widget.dart';
import 'friends_controller.dart';
import '../events/events_page.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  late FriendsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FriendsController(context);
    _controller.fetchFriends();
  }

  void _showAddFriendDialog() {
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _controller.addNewFriend(emailController.text);
                  if(context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                  }
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return SmartWidget(
          title: 'My Friends',
          newButton: NewButton(
            label: 'New Friend',
            onPressed: _showAddFriendDialog,
          ),
          topWidget: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _controller.searchController,
              autofocus: false,
              decoration: const InputDecoration(
                label: Text('search'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          filterButtons: const [],
          sortOptions: const [],
          tileBuilder: (context, index) {
            final friend = _controller.filteredFriends[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person_outline, color: Colors.black54),
              ),
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0,8,0,8.0),
                child: Text(friend.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              ),
              trailing: FutureBuilder<int>(
                future: _controller.getUpcomingEventsCount(friend.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data == 0) {
                    return const SizedBox();
                  } else {
                    return Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          snapshot.data!.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsPage(
                      userUid: friend.id,
                      userDisplayName: friend.name,
                    ),
                  ),
                );
              },
            );
          },
          itemCount: _controller.filteredFriends.length,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
