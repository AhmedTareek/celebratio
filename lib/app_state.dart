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
  final Map<String, String> userNames = {};
  late StreamSubscription<QuerySnapshot> _customSubscription;

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
      if (_isOnline && loggedIn) {
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
        // removeDeviceToken();
      }
      notifyListeners();
    });

    // subscribe to changes in the events doc
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      notifyListeners();
    });
  }

  subscribeToEventByCreatorId(String creatorId) {
    _customSubscription = FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: creatorId) // condition for filtering
        .snapshots()
        .listen((event) {
      print('notifying listeners about events');
      notifyListeners();
    });
  }

  unsubscribeFromEventByCreatorId() {
    _customSubscription.cancel();
  }

  subscribeToGiftsByEventId(String eventId) {
    _customSubscription = FirebaseFirestore.instance
        .collection('gifts')
        .where('event', isEqualTo: eventId) // condition for filtering
        .snapshots()
        .listen((event) {
      print('notifying listeners about gifts');
      notifyListeners();
    });
  }

  unsubscribeFromGiftsByEventId() {
    _customSubscription.cancel();
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
    }
  }

  Future<void> _syncEvent(FbEvent event) async {
    try {
      switch (event.syncAction) {
        case 'insert':
          final eventRef =
              FirebaseFirestore.instance.collection('events').doc(event.id);
          await eventRef.set(event.toFirestore());
          // Add the event in the user's events list
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'events': FieldValue.arrayUnion([eventRef.id]),
          });
          // Update the event with the firestore id and mark it as synced
          // event = await _localDb.changeEventId(event, eventRef.id);
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
          final giftRef =
              FirebaseFirestore.instance.collection('gifts').doc(gift.id);
          // gift = await _localDb.changeGiftId(gift, giftRef.id);
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
  Future<void> publishGift(FbGift gift) async {
    gift = await _localDb.publishGift(gift);
    if (_isOnline) await _syncWithFirestore();
  }

  Future<void> addGift(FbGift gift) async {
    final localId = const Uuid().v4();
    gift.id = localId;
    gift = await _localDb.insertNewGift(gift);
    if (_isOnline && gift.syncAction != 'draft') await _syncGift(gift);
  }

  Future<bool> updateGift(FbGift gift) async {
    var localGift = await _localDb.getGiftById(gift.id);
    if (localGift.syncAction != null && localGift.syncAction == 'draft') {
      localGift = await _localDb.updateGift(gift);
      return true;
    }
    // no updating for gifts allowed when offline
    // because someone may have pledged it but if the gift is made in offline
    // and not synced yet then we can update it
    if (!_isOnline) {
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
    var localGift = await _localDb.getGiftById(giftId);
    if (localGift.syncAction == 'draft') {
      await _localDb.deleteGiftById(giftId, needSync: false);
      return true;
    }
    if (!_isOnline) {
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

  Future<void> publishEvent(FbEvent event) async {
    event = await _localDb.publishEvent(event);
    if (_isOnline) await _syncWithFirestore();
    // notifyListeners();
  }

  Future<void> addEvent(FbEvent event) async {
    final localId = const Uuid()
        .v4(); // thats like a temp id till we sync it with firestore
    event.id = localId;
    event = await _localDb.insertNewEvent(event);
    if (_isOnline && event.syncAction != 'draft') await _syncEvent(event);
  }

  Future<void> updateEvent(FbEvent event) async {
    event = await _localDb.updateEvent(event);
    if (_isOnline && event.syncAction != 'draft') await _syncEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    var event = await _localDb.deleteEventById(eventId);
    if (_isOnline &&
        (event.syncAction != 'draft' || event.syncAction != 'insert')) {
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
    // get drafted gifts
    final draftedGifts = await _localDb.getDraftGiftsByEventId(eventId);

    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('event', isEqualTo: eventId)
        .get();
    // create from firestore then return a list of FbGift objects
    List<FbGift> gifts = giftsQuery.docs
        .map((doc) => FbGift.fromFirestore(doc.data(), doc.id))
        .toList();
    gifts.addAll(draftedGifts);
    return gifts;
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
    List<FbEvent> events = eventsQuery.docs
        .map((doc) => FbEvent.fromFirestore(doc.data(), doc.id))
        .toList();
    // get drafted events
    if (friendId == FirebaseAuth.instance.currentUser!.uid) {
      final draftedEvents = await _localDb.getDraftEvents();
      events.addAll(draftedEvents);
    }
    return events;
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

    // Query for gifts pledged by the current user
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('pledgedBy', isEqualTo: currentUser.uid)
        .get();

    // Collect all unique event IDs from the gifts
    final List<String> eventIds = giftsQuery.docs
        .map((doc) => doc.data()['event'] as String)
        .toSet()
        .toList();

    // Fetch all events in one go
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where(FieldPath.documentId, whereIn: eventIds)
        .get();

    // Create a map for quick event data access
    Map<String, Map<String, dynamic>> eventsMap = {};
    for (var eventDoc in eventsSnapshot.docs) {
      eventsMap[eventDoc.id] = eventDoc.data();
    }

    List<PledgedGift> pledgedGifts = [];
    for (final giftDoc in giftsQuery.docs) {
      final gift = giftDoc.data();
      final eventId = gift['event'] as String;

      if (eventsMap.containsKey(eventId)) { // Ensure the event was fetched
        pledgedGifts.add(
            PledgedGift.fromData(gift, giftDoc.id, eventsMap[eventId]!));
      }
    }

    return pledgedGifts;
  }

  Future<List<PledgedGiftToMe>> getGiftsToBeGivenToMe() async {
    if (!_isOnline) {
      return [];
    }

    final currentUser = FirebaseAuth.instance.currentUser!;

    // Fetch user document to get eventIds
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    List<String> eventIds = List<String>.from(userDoc.data()?['events'] ?? []);

    // Query for gifts where event is in eventIds and pledgedBy is not null
    final giftsQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('event', whereIn: eventIds)
        .where('pledgedBy', isNull: false)
        .get();
    print("here 1");
    // Fetch all relevant events in one go
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where(FieldPath.documentId, whereIn: eventIds)
        .get();
    print("here 2");
    // Create a map for quick lookup of events
    Map<String, Map<String, dynamic>> eventsMap = {};
    for (var eventDoc in eventsSnapshot.docs) {
      eventsMap[eventDoc.id] = eventDoc.data();
    }
    print("here 3");
    List<PledgedGiftToMe> giftsToMe = [];
    for (final giftDoc in giftsQuery.docs) {
      final gift = giftDoc.data();
      final eventId = gift['event'] as String;
      print("here 4");
      // Check if the event was created by the current user
      if (eventsMap[eventId]?['createdBy'] == currentUser.uid) {
        print("here 5");
        print("gift: $gift, giftDocId: ${giftDoc.id}, event: ${eventsMap[eventId]}");
        var pledgedGiftToMe = PledgedGiftToMe.fromData(gift, giftDoc.id, eventsMap[eventId]!);
        print("here 6");
        giftsToMe.add(pledgedGiftToMe);
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
      {required String creatorId,
      required String giftId,
      required Map<String, String> updatedData}) async {
    // no pledging for gifts allowed when offline
    if (!_isOnline) {
      return false;
    }
    final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftId);
    // check if the status of the gift is pledged then refuse any edits
    final giftDoc = await giftRef.get();
    if (giftDoc.data()!['status'] == 'Pledged') {
      return false;
    }
    await giftRef.update(updatedData);
    // get the token of the creator he may have no token
    final creatorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(creatorId)
        .get();
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
  // (this needs to be solved as the user id will not be available after sigout)
  Future<void> removeDeviceToken() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'token': FieldValue.delete()});
  }
}
