import 'dart:async';

import 'package:celebratio/Model/fb_Friend.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import 'Model/fb_pledged_gift.dart';
import 'Model/fb_pledged_gifts_to_me.dart';
import 'Model/local_db.dart';
import 'firebase_options.dart';
import 'notification_manager.dart';

class ApplicationState extends ChangeNotifier {
  final DataBase _localDb = DataBase();
  bool _isOnline = false;

  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Initialize connectivity monitoring
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _isOnline = result.first != ConnectivityResult.none;
      if (_isOnline) {
        _syncWithFirestore();
      }
      notifyListeners();
    });

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        initNotificationManager();
      } else {
        _loggedIn = false;
        removeDeviceToken();
      }
      notifyListeners();
    });

    // subscribe to changes in the events doc
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      notifyListeners();
    });
  }

  Future<void> _syncWithFirestore() async {
    if (!_isOnline) return;

    // Sync events
    final unsyncedEvents = await _localDb.getUnSyncedEvents();
    for (var event in unsyncedEvents) {
      await _syncEvent(event);
    }

    // Sync gifts
    final unsyncedGifts = await _localDb.getUnSyncedGifts();
    for (var gift in unsyncedGifts) {
      await _syncGift(gift);
    }

    // Sync if any gift was pledged to me from firestore to local db
    final giftsToMe = await getGiftsToBeGivenToMe();
    // update their status and pledgedBy in local db
    for (var gift in giftsToMe) {
      await _localDb.updateGift(gift.gift, needSync: false);
      print("gift to be updated${gift.gift}");
    }
  }

  Future<void> _syncEvent(FbEvent event) async {
    try {
      switch (event.syncAction) {
        case 'insert':
          print("syncing insert event");
          final eventRef =
              FirebaseFirestore.instance.collection('events').doc();
          await eventRef.set(event.toFirestore());
          print("eventRef: $eventRef");
          // Add the event in the user's events list
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'events': FieldValue.arrayUnion([eventRef.id]),
          });
          // Update the event with the firestore id and mark it as synced
          event = await _localDb.changeEventId(event, eventRef.id);
          await _localDb.markSynced('events', event.id!);
          break;
        case 'update':
          await FirebaseFirestore.instance
              .collection('events')
              .doc(event.id)
              .update(event.toFirestore());
          await _localDb.markSynced('events', event.id!);
          break;
        case 'delete':
          await _deleteEventFromFirestore(event.id!);
          await _localDb.deleteEventById(event.id!, needSync: false);
          break;
      }
    } catch (e) {
      print('Event sync failed: ${e.toString()}');
    }
  }

  Future<void> _syncGift(FbGift gift) async {
    try {
      switch (gift.syncAction) {
        case 'insert':
          final giftRef = FirebaseFirestore.instance.collection('gifts').doc();
          gift = await _localDb.changeGiftId(gift, giftRef.id);
          await giftRef.set(gift.toFirestore());
          await _localDb.markSynced('gifts', gift.id);
          break;
        case 'update':
          await FirebaseFirestore.instance
              .collection('gifts')
              .doc(gift.id)
              .update(gift.toFirestore());
          await _localDb.markSynced('gifts', gift.id);
          break;
        case 'delete':
          await FirebaseFirestore.instance
              .collection('gifts')
              .doc(gift.id)
              .delete();
          await _localDb.deleteGiftById(gift.id, needSync: false);
          break;
      }
    } catch (e) {
      print('Gift sync failed: ${e.toString()}');
    }
  }

  //-------------------------------------------------------
  Future<void> addGift(FbGift gift) async {
    final localId = const Uuid().v4();
    gift.id = localId;
    gift = await _localDb.insertNewGift(gift);
    if (_isOnline) await _syncGift(gift);
  }

  Future<bool> updateGift(FbGift gift) async {
    // no updating for gifts allowed when offline
    // because someone may have pledged it but if the gift is made in offline
    // and not synced yet then we can update it
    if (!_isOnline) {
      var localGift = await _localDb.getGiftById(gift.id);
      if (localGift.syncAction == 'insert') {
        // this is not synced yet so we can update it
        localGift = await _localDb.updateGift(gift);
        return true;
      }
      return false;
    }
    // check if the status of the gift is pledged then refuse any updates
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(gift.id);
    final giftDoc = await giftRef.get();
    if (giftDoc.data()!['status'] == 'Pledged') {
      return false;
    }
    gift = await _localDb.updateGift(gift);
    await _syncGift(gift);
    return true;
  }

  Future<bool> deleteGift(String giftId) async {
    // no deleting for gifts allowed when offline because someone may have pledged it
    // but if the gift is made in offline and not synced yet then we can delete it

    if (!_isOnline) {
      var localGift = await _localDb.getGiftById(giftId);
      if (localGift.syncAction == 'insert') {
        // this is not synced yet so we can delete it
        await _localDb.deleteGiftById(giftId, needSync: false);
        return true;
      }
      return false;
    }
    // check if the status of the gift is pledged then refuse any deletes
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    final giftDoc = await giftRef.get();
    if (giftDoc.data()!['status'] == 'Pledged') {
      return false;
    }
    await _localDb.deleteGiftById(giftId);
    try {
      await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();
      return true;
    } catch (e) {
      print('Failed to delete gift: $e');
      return false;
    }
  }

  Future<void> addEvent(FbEvent event) async {
    final localId = const Uuid()
        .v4(); // thats like a temp id till we sync it with firestore
    event.id = localId;
    event = await _localDb.insertNewEvent(event);
    print("am i online? $_isOnline");
    if (_isOnline) await _syncEvent(event);
  }

  Future<void> updateEvent(FbEvent event) async {
    event = await _localDb.updateEvent(event);
    if (_isOnline) await _syncEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _localDb.deleteEventById(eventId);
    if (_isOnline) {
      try {
        await _deleteEventFromFirestore(eventId);
        await _localDb.deleteEventById(eventId, needSync: false);
      } catch (e) {
        print('Failed to delete event: $e');
      }
    }
  }

  Future<void> _deleteEventFromFirestore(String eventId) async {
    try {
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
    } catch (e) {
      print('Failed to delete event: $e');
    }
  }

  //-------------------------------------------------------

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

  Future<List<FbGift>> getGiftsByEventId(String eventId) async {
    // if not online get from local db
    if (!_isOnline) {
      final localGifts = await _localDb.getGiftsByEventId(eventId);
      if (localGifts.isNotEmpty) {
        return localGifts;
      }
    }
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('event', isEqualTo: eventId)
        .get();
    // create from firestore then return a list of FbGift objects
    return giftsQuery.docs
        .map((doc) => FbGift.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<FbEvent>> getEventsByFriendId(String friendId) async {
    // if not online get from local db
    if (!_isOnline && friendId == FirebaseAuth.instance.currentUser!.uid) {
      final localEvents = await _localDb.getEvents();
      if (localEvents.isNotEmpty) {
        return localEvents;
      }
    }
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
    if (!_isOnline) {
      return [];
    }

    final currentUser = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final friendIds = List<String>.from(userDoc['friends'] ?? []);
    if (friendIds.isEmpty) {
      return [];
    }
    final friendsQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();
    // create from firestore then return a list of Friend objects
    return friendsQuery.docs
        .map((doc) => FbFriend.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<PledgedGift>> getMyPledgedGifts() async {
    if (!_isOnline) {
      return [];
    }
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
    if (!_isOnline) {
      return [];
    }
    final currentUser = FirebaseAuth.instance.currentUser!;
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('pledgedBy', isNull: false)
        .get();

    List<PledgedGiftToMe> giftsToMe = [];
    print("Raw documents: ${giftsQuery.docs.map((doc) => doc.data())}");

    for (final giftDoc in giftsQuery.docs) {
      final gift = giftDoc.data();
      print("giffffffft data: $gift");
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(gift['event'])
          .get();
      final event = eventDoc.data();
      print('the event is $event');

      if (event?['createdBy'] == currentUser.uid) {
        print('event created by me');
        var pledgedGiftToMe = PledgedGiftToMe.fromData(gift, giftDoc.id, event);
        giftsToMe.add(pledgedGiftToMe);
        print("gifts to me: $giftsToMe");
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
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()!['name'];
  }

  Future<bool> pledgeGift(
      {
        required String creatorId,
        required String giftId,
      required Map<String, String> updatedData}) async {
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    // check if the status of the gift is pledged then refuse any edits
    final giftDoc = await giftRef.get();
    if (giftDoc.data()!['status'] == 'Pledged') {
      return false;
    }
    await giftRef.update(updatedData);
    // get the token of the creator he may have no token
    final creatorDoc = await FirebaseFirestore.instance.collection('users').doc(creatorId).get();
    final creatorToken = creatorDoc.data()!['token'];
    if (creatorToken != null) {
       NotificationManager.sendNotification(
          targetToken: creatorToken,
          title: 'Gift Pledged',
          body: 'Your gift ${giftDoc.data()!['name']} has been pledged');
    }
    return true;
  }

  // init NotificationManager and save the token to the firestore
  Future<void> initNotificationManager() async {
    await NotificationManager.initialize();
    String? token = await NotificationManager.getDeviceToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'token': token});
    }
  }
  // remove the device token from the firestore
  Future<void> removeDeviceToken() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'token': FieldValue.delete()});
  }

}
