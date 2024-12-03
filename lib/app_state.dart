import 'dart:async';

import 'package:celebratio/Model/fb_Friend.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';

import 'Model/fb_pledged_gift.dart';
import 'Model/fb_pledged_gifts_to_me.dart';
import 'firebase_options.dart';
import 'Model/friend.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _friendsSubscription;
  List<Friend> _friends = [];

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  Future<void> addFriend({
    required String email,
  }) async {
    // find the id of the user having the email
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'friends': FieldValue.arrayUnion([user.docs.first.id])
    });
  }

  Future<void> addEvent({
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String category,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final eventRef = FirebaseFirestore.instance.collection('events').doc();

    await eventRef.set({
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'createdBy': currentUser.uid,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'events': FieldValue.arrayUnion([eventRef.id]),
    });
  }

  Future<void> addGift({
    required String eventId,
    required String name,
    required String description,
    required String category,
    required double price,
    String? imageUrl,
  }) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc();

    await giftRef.set({
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': 'Available',
      'event': eventId,
      'imageUrl': imageUrl,
      'pledgedBy': null,
    });
  }

  Future<List<FbGift>> getGiftsByEventId(String eventId) async {
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('event', isEqualTo: eventId)
        .get();
    // create from firestore then return a list of FbGift objects
    return giftsQuery.docs
        .map((doc) => FbGift.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<FbEvent>> getFriendsEvents() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final friendIds = List<String>.from(userDoc['friends'] ?? []);

    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', whereIn: friendIds)
        .get();
    // create from firestore then return a list of FbEvent objects
    return eventsQuery.docs
        .map((doc) => FbEvent.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<FbEvent>> getMyEvents() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final eventIds = List<String>.from(userDoc['events'] ?? []);

    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where(FieldPath.documentId, whereIn: eventIds)
        .get();
    // create from firestore then return a list of FbEvent objects
    return eventsQuery.docs
        .map((doc) => FbEvent.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<FbEvent>> getEventsByFriendId(String friendId) async {
    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: friendId)
        .get();
    // create from firestore then return a list of FbEvent objects
    print("Events Query: $eventsQuery" + "finshed");
    return eventsQuery.docs
        .map((doc) => FbEvent.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<FbFriend>> getFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final friendIds = List<String>.from(userDoc['friends'] ?? []);

    final friendsQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();
    // create from firestore then return a list of Friend objects
    return friendsQuery.docs
        .map((doc) => FbFriend.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> editGift({
    required String giftId,
    required Map<String, dynamic> updatedData,
  }) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    await giftRef.update(updatedData);
  }

  Future<void> deleteGift({required String giftId}) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    await giftRef.delete();
  }


  Future<void> editEvent({
    required String eventId,
    required Map<String, dynamic> updatedData,
  }) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    await eventRef.update(updatedData);
  }

  Future<void> deleteEvent({required String eventId}) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    await eventRef.delete();
  }

  Future<List<PledgedGift>> getMyPledgedGifts() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('pledgedBy', isEqualTo: currentUser.uid)
        .get();

    List<PledgedGift> pledgedGifts = [];
    for (final giftDoc in giftsQuery.docs) {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(giftDoc.data()['event'])
          .get();

      pledgedGifts.add(
          PledgedGift.fromData(giftDoc.data(), giftDoc.id, eventDoc.data())
      );
    }

    return pledgedGifts;
  }


  Future<List<PledgedGiftToMe>> getGiftsToBeGivenToMe() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('pledgedBy', isNotEqualTo: null)
        .get();

    List<PledgedGiftToMe> giftsToMe = [];
    for (final giftDoc in giftsQuery.docs) {
      final gift = giftDoc.data();
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(gift['event'])
          .get();
      final event = eventDoc.data();

      if (event?['createdBy'] == currentUser.uid) {
        giftsToMe.add(
            PledgedGiftToMe.fromData(gift, giftDoc.id, event)
        );
      }
    }

    return giftsToMe;
  }



}
