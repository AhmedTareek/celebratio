import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Authentication flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Start the app
    await app.main();

    await tester.pumpAndSettle();
    // Ensure the welcome page is displayed
    // expect(find.text('Welcome to Celebratio!'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    // Press the 'Skip' button
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();

    // Check if we're now on the login page
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Enter username and password
    await tester.enterText(find.byType(TextField).first, 'email');
    await tester.enterText(find.byType(TextField).last, 'pass');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Find and tap the login button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign in'));
    await tester.pumpAndSettle();

    // Wait for authentication to complete
    // Here you might need to implement a way to check if authentication has completed:
    // This could be waiting for a specific widget to appear or disappear, or checking for a state change
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Wait for 5 seconds as an example

    // Verify if authentication was successful (this part depends on your app's UI after login)
    expect(find.text('Friends'),
        findsOneWidget); // Assuming 'Dashboard' shows after login

    // check there is events button in navigation bar
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    // click on events button
    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    // wait for 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on add event button
    await tester.tap(find.byIcon(Icons.add));
    // wait for 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 1));
// fill the event form
    await tester.enterText(
        find.widgetWithText(TextField, 'Event Name'), 'My Birthday Party');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Select Event Date'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.text('OK')); // Assuming the date picker has an 'OK' button
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.enterText(
        find.widgetWithText(TextField, 'Location'), 'Central Park');

    await tester.enterText(find.widgetWithText(TextField, 'Description'),
        'A fun birthday party with friends and family.');

    await tester.enterText(
        find.widgetWithText(TextField, 'Category'), 'Birthday');

    // save the event
    await tester.tap(find.widgetWithText(OutlinedButton, 'Save Event'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    // click on current events button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Current'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // check if the event is saved
    expect(find.text('My Birthday Party'), findsOneWidget);
    // tap on the event
    await tester.tap(find.text('My Birthday Party'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on add gift button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // fill the gift form
    await tester.enterText(
        find.widgetWithText(TextField, 'Name'), 'Toy Car');

    await tester.enterText(find.widgetWithText(TextField, 'Price'), '20');

    await tester.enterText(find.widgetWithText(TextField, 'Description'),
        'A toy car for the birthday boy.');

    await tester.enterText(
        find.widgetWithText(TextField, 'Category'), 'Toys');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // scroll down
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add Gift'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    // check if the gift is saved
    expect(find.text('Toy Car'), findsOneWidget);
    // wait for 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on profile button
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on logout button
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);

    // Press the 'Skip' button
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check if we're now on the login page
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Enter username and password
    await tester.enterText(find.byType(TextField).first, 'email2');
    await tester.enterText(find.byType(TextField).last, 'pass2');
    // Find and tap the login button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign in'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // click on Ahmed
    await tester.tap(find.text('Ahmed'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // click on current events button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Current'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // check if the event is saved
    expect(find.text('My Birthday Party'), findsOneWidget);
    // tap on the event
    await tester.tap(find.text('My Birthday Party'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // check if the gift is saved
    expect(find.text('Toy Car'), findsOneWidget);
    // click on the gift
    await tester.tap(find.text('Toy Car'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // pledge the gift
    await tester.tap(find.text('Pledge This Gift'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // go back to the event
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on profile button
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // click on logout button
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    // Press the 'Skip' button
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check if we're now on the login page
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Enter username and password
    await tester.enterText(find.byType(TextField).first, 'email');
    await tester.enterText(find.byType(TextField).last, 'pass');

    // Find and tap the login button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // click on in gift icon
    await tester.tap(find.byIcon(Icons.card_giftcard));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // check if the gift appears
    expect(find.text('Toy Car'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));




    // Additional checks or interactions can go here
  });
}
