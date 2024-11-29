import 'package:celebratio/event_details_page.dart';
import 'package:celebratio/InGifts.dart';
import 'package:celebratio/OutGifts.dart';
import 'package:celebratio/Profile.dart';
import 'package:flutter/material.dart';

import 'events_page.dart';
import 'friends_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/Friends': (context) => Friends(),
        '/Profile':(context) => Profile(),
      },
      title: 'Celebratio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed( // 0xFF10375C
            seedColor: Color(0xFF10375C), brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> pages = [
    EventsPage(),
    Friends(),
    Card(),
    InGifts(),
    OutGifts(),
  ];
  var _selectedIdx = 1;

  String getGreeting() {
    var now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    const radius = 20.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: _selectedIdx == 0 || _selectedIdx == 1 || _selectedIdx == 3 || _selectedIdx == 4
          ? pages[_selectedIdx]
          : pages[1],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_month_rounded), label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.people_alt_rounded), label: 'Friends'),
          NavigationDestination(icon: Icon(Icons.feed_rounded), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.cake_rounded), label: 'In'),
          NavigationDestination(
              icon: Icon(Icons.checklist_rounded), label: 'out'),
        ],
        selectedIndex: _selectedIdx,
        onDestinationSelected: (index) {
          _selectedIdx = index;
          setState(() {});
        },
      ),
    );
  }

// // this is going to be deleted //https://colorhunt.co/palette/f4f6fff3c623eb831710375c
//   Widget homeColumn(
//       ThemeData theme, double radius, TextStyle style, BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.account_circle),
//           onPressed: () {},
//         ),
//         title: Text(
//           'Celebratio',
//           style: TextStyle(color: theme.primaryColor),
//         ),
//         actions: [
//           ElevatedButton.icon(
//             onPressed: () {},
//             label: const Text('New Event'),
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               '${getGreeting()}, Ahmed',
//               style:
//                   theme.textTheme.displaySmall?.copyWith(color: Colors.black54),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10375C),
//                     //const Color(0xFFB7E0FF),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radius),
//                     )),
//                 child: Text(
//                   'My Events',
//                   style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/Friends',
//                       arguments: {'colorCode': '0xFFFFF5CD'});
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10375C), // const Color(0xFFFFF5CD),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radius),
//                     )),
//                 child: Text(
//                   'Friends',
//                   style: style.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor:const Color(0xFF10375C), //const Color(0xFFFFCFB3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radius),
//                     )),
//                 child: Text(
//                   'Gifts Out',
//                   style: style.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10375C), //const Color(0xFFE78F81),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(radius),
//                     )),
//                 child: Text(
//                   'Gifts In',
//                   style: style.copyWith(fontWeight: FontWeight.bold,color : Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}
