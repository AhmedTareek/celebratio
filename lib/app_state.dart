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

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

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

    // subscribe to changes in the events doc
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
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

  Future<void> addEvent(FbEvent event) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final eventRef = FirebaseFirestore.instance.collection('events').doc();

    await eventRef.set(event.toFirestore());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'events': FieldValue.arrayUnion([eventRef.id]),
    });
  }

  Future<void> addGift(FbGift gift) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc();
    await giftRef.set(gift.toFirestore());
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

  Future<bool> editGift({
    required String giftId,
    required Map<String, dynamic> updatedData,
  }) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    // check if the status of the gift is pledged then refuse any edits
    final giftDoc = await giftRef.get();
    if (giftDoc.data()!['status'] == 'Pledged') {
      return false;
    }
    await giftRef.update(updatedData);
    return true;
  }

  Future<void> deleteGift({required String giftId}) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    await giftRef.delete();
  }

  Future<void> editEvent({
    required String eventId,
    required Map<String, dynamic> updatedData,
  }) async {
    final eventRef =
        FirebaseFirestore.instance.collection('events').doc(eventId);
    await eventRef.update(updatedData);
  }

  Future<void> deleteEvent({required String eventId}) async {
    final eventRef =
        FirebaseFirestore.instance.collection('events').doc(eventId);
    await eventRef.delete();
    // delete all gifts associated with the event
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('event', isEqualTo: eventId)
        .get();
    for (final giftDoc in giftsQuery.docs) {
      await giftDoc.reference.delete();
    }
    // delete the event from the current user document
    final currentUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'events': FieldValue.arrayRemove([eventId]),
    });
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
          PledgedGift.fromData(giftDoc.data(), giftDoc.id, eventDoc.data()));
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
        giftsToMe.add(PledgedGiftToMe.fromData(gift, giftDoc.id, event));
      }
    }

    return giftsToMe;
  }

  // get upcoming events count by user id
  Future<int> getUpcomingEventsCountByUserId(String userId) async {
    final now = DateTime.now().toIso8601String();
    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: now)
        .get();
    return eventsQuery.docs.length;
  }

  // get the name of the user by id
  Future<String> getUserNameById(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()!['name'];
  }
}
