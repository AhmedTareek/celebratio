import 'package:celebratio/incoming_gifts_page.dart';
import 'package:celebratio/outgoing_gifts_page.dart';
import 'package:celebratio/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'Authentication/authentication.dart';
import 'app_state.dart';
import 'events_page.dart';
import 'friends_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, child) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Celebratio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            // 0xFF10375C
            seedColor: Color(0xFF10375C),
            brightness: Brightness.light),
        useMaterial3: true,
      ),
      // home: const MyHomePage(),
      routerConfig: _router,
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
    final bool isLoggedIn = Provider.of<ApplicationState>(context).loggedIn;

    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      body: isLoggedIn? _selectedIdx == 0 ||
              _selectedIdx == 1 ||
              _selectedIdx == 3 ||
              _selectedIdx == 4
          ? pages[_selectedIdx]
          : pages[1]
      :  const SignInWidget(),
      bottomNavigationBar: isLoggedIn? NavigationBar(
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
      ): null,
    );

  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return const SignInWidget();
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
    GoRoute(path: '/profile', builder: (context, state) => const Profile()),
  ],
);

class SignInWidget extends StatelessWidget {
  const SignInWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        ForgotPasswordAction(((context, email) {
          final uri = Uri(
            path: '/sign-in/forgot-password',
            queryParameters: <String, String?>{
              'email': email,
            },
          );
          context.push(uri.toString());
        })),
        AuthStateChangeAction(((context, state) async {
          final user = switch (state) {
            SignedIn state => state.user,
            UserCreated state => state.credential.user,
            _ => null
          };
          if (user == null) {
            return;
          }
          if (state is UserCreated) {
            user.updateDisplayName(user.email!.split('@')[0]);
            // Add the new user to the Firestore database
            final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

            await userDocRef.set({
              'name': user.displayName ?? user.email!.split('@')[0],
              'email': user.email ?? '',
              'phoneNumber': user.phoneNumber ?? '',
              'friends': [],
              'events': [],
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          if (!user.emailVerified) {
            user.sendEmailVerification();
            const snackBar = SnackBar(
                content: Text(
                    'Please check your email to verify your email address'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          context.pushReplacement('/');
        })),
      ],
    );
  }
}
