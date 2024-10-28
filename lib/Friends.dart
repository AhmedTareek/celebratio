import 'package:celebratio/CustomWidget.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return CustomWidget(
      title: 'My Friends',
      newButton: NewButton(label: 'New Friend',onPressed: (){}),
        topWidget: const Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            autofocus: false,
            decoration: InputDecoration(
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
            leading: const CircleAvatar(),
            title: Text('Friend $index'),
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
        itemCount: 35);

  }

}


