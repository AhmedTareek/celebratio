import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Friends/friends_page.dart';
import 'app_state.dart';
import 'events/events_page.dart';
import 'in_out_gifts.dart';
import 'introduction_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedIdx = 1;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<ApplicationState>(context).loggedIn;
    List<Widget> pages = [];
    if (isLoggedIn) {
      pages = [
        EventsPage(
          userUid: isLoggedIn ? FirebaseAuth.instance.currentUser!.uid : null,
        ),
        const Friends(),
        const InOutGifts(key: ValueKey('incoming_gifts'), isIncoming: true),
        const InOutGifts(key: ValueKey('outgoing_gifts'), isIncoming: false),
      ];
    }

    return Scaffold(
      body: isLoggedIn ? pages[_selectedIdx] : const IntroductionScreenPage(),
      bottomNavigationBar: isLoggedIn
          ? NavigationBar(
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.calendar_month_rounded), label: 'Events'),
                NavigationDestination(
                    icon: Icon(Icons.people_alt_rounded), label: 'Friends'),
                NavigationDestination(
                    icon: Icon(Icons.card_giftcard), label: 'In'),
                NavigationDestination(
                    icon: Icon(Icons.checklist_rounded), label: 'Out'),
              ],
              selectedIndex: _selectedIdx,
              onDestinationSelected: (index) {
                _selectedIdx = index;
                setState(() {});
              },
            )
          : null,
    );
  }
}
