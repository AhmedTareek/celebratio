import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class SignInWidget extends StatelessWidget {

  const SignInWidget({super.key});

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
          if(state is SignedIn) {
            var appState = Provider.of<ApplicationState>(context, listen: false);
            appState.initNotificationManager();
            appState.fetchAndStoreUserEventsAndGifts();

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
            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
          if(context.mounted) {
            context.pushReplacement('/');
          }
        })),
      ],
    );
  }

}