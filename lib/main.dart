import 'package:celebratio/incoming_gifts_page.dart';
import 'package:celebratio/outgoing_gifts_page.dart';
import 'package:celebratio/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'app_state.dart';
import 'events/events_page.dart';
import 'Friends/friends_page.dart';

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
    List<Widget> pages = [];
    if (isLoggedIn) {
      pages = [
        EventsPage(
          userUid: isLoggedIn ? FirebaseAuth.instance.currentUser!.uid : null,
        ),
        Friends(),
        Card(),
        InGifts(),
        OutGifts(),
      ];
    }

    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      body: isLoggedIn
          ? _selectedIdx == 0 ||
                  _selectedIdx == 1 ||
                  _selectedIdx == 3 ||
                  _selectedIdx == 4
              ? pages[_selectedIdx]
              : pages[1]
          : const IntroductionScreenPage(),
      bottomNavigationBar: isLoggedIn
          ? NavigationBar(
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.calendar_month_rounded), label: 'Events'),
                NavigationDestination(
                    icon: Icon(Icons.people_alt_rounded), label: 'Friends'),
                NavigationDestination(
                    icon: Icon(Icons.feed_rounded), label: 'Feed'),
                NavigationDestination(
                    icon: Icon(Icons.cake_rounded), label: 'In'),
                NavigationDestination(
                    icon: Icon(Icons.checklist_rounded), label: 'out'),
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

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
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
                    final userDocRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid);

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
                DisplayNameChangedAction((context, oldName, newName) {
                  //update users document with the new name
                  final user = FirebaseAuth.instance.currentUser;
                  final userDocRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid);
                  userDocRef.update({'name': newName});
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

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Celebratio'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  context.go('/sign-in');
                },
                child: Text('Get Started')),
          ],
        ),
      ),
    );
  }
}

class IntroductionScreenPage extends StatefulWidget {
  const IntroductionScreenPage({super.key});

  @override
  State<IntroductionScreenPage> createState() => _IntroductionScreenPageState();
}

class _IntroductionScreenPageState extends State<IntroductionScreenPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(BuildContext context) {
    context.go('/sign-in'); // Navigate to sign-in page when intro ends
  }

  Widget _buildImage(String assetName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(250.0),
      // Adjust this value for roundness
      child: Image.asset(
        'asset/images/$assetName',
        width: 350,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Welcome to Celebratio!",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(250.0),
                child: Image.asset(
                  'asset/images/Celebration.png',
                  width: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20), // Space between image and body
              const Text(
                "Discover the joy of celebrating with friends.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19.0),
              ),
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Connect with Friends",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(250.0),
                child: Image.asset(
                  'asset/images/Friends.png',
                  width: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Easily manage and share events with your close ones.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19.0),
              ),
            ],
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text(
        "Get Started",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

}
