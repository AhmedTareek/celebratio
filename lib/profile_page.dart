import 'package:celebratio/app_state.dart';
import 'package:celebratio/notification_manager.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'events/events_page.dart';
import 'in_out_gifts.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  // State for the notification toggle switch
  bool _notificationsEnabled = true;
  late ApplicationState appState;
  @override
  void initState() {
    super.initState();
    appState = Provider.of<ApplicationState>(context, listen: false);
    _loadNotificationPreference();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providers: const [],
      actions: [
        SignedOutAction((context) {
          context.pushReplacement('/');
          appState.deleteAllLocalData();
          appState.removeNotificationDeviceToken();
        }),
        DisplayNameChangedAction((context, oldName, newName) {
          appState.updateUserName(newName);
        }),
      ],
      children: [
        // Notification Toggle Switch
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
              _saveNotificationPreference(value);
              if (value) {
                appState.initNotificationManager();
              } else {
                NotificationManager.disableNotifications();
              }
            });
          },
          // activeColor: Colors.blue,
          // inactiveThumbColor: Colors.grey,
        ),
        // Styled Elevated Button for navigating to incoming gifts
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: OutlinedButton(
            style: TextButton.styleFrom(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InOutGifts(isIncoming: true)),
              );
            },
            child: const Text('My Incoming Gifts'),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventsPage()),
            );
          },
          child: const Text('My Events'),
        )
      ],
    );
  }

  // Method to load the notification preference from shared preferences
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  // Method to save the notification preference to shared preferences
  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }
}
