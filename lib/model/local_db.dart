import 'dart:developer';

import 'package:path/path.dart';
import 'package:celebratio/model/event.dart';
import 'package:celebratio/model/gift.dart';
import 'package:sqflite/sqflite.dart';

class DataBase {
  static Database? _myDataBase;

  Future<Database?> get myDataBase async {
    if (_myDataBase == null) {
      _myDataBase = await initialize();
      return _myDataBase;
    }
    return _myDataBase;
  }

  static const _version = 10;

  initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    Database myDB = await openDatabase(path, version: _version,
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS events (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          date TEXT,
          location TEXT,
          category TEXT,
          createdBy TEXT,
          needSync INTEGER DEFAULT 0,
          syncAction TEXT,
          lastModified INTEGER
        )
      ''');

      // Create Gifts table with sync status
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gifts (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          category TEXT,
          price REAL,
          status TEXT,
          eventId TEXT,
          imageUrl TEXT,
          pledgedBy TEXT,
          needSync INTEGER DEFAULT 0,
          syncAction TEXT,
          lastModified INTEGER
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < newVersion) {
        log("Upgrading database from version $oldVersion to $newVersion");
        // delete all rows in event table and gifts table
        await db.execute('DELETE FROM events');
        await db.execute('DELETE FROM gifts');

        //   // Create Events table with sync status
        //   await db.execute('''
        //   CREATE TABLE IF NOT EXISTS events (
        //     id TEXT PRIMARY KEY,
        //     name TEXT,
        //     description TEXT,
        //     date TEXT,
        //     location TEXT,
        //     category TEXT,
        //     createdBy TEXT,
        //     needSync INTEGER DEFAULT 0,
        //     syncAction TEXT,
        //     lastModified INTEGER
        //   )
        // ''');
        //
        //   // Create Gifts table with sync status
        //   await db.execute('''
        //   CREATE TABLE IF NOT EXISTS gifts (
        //     id TEXT PRIMARY KEY,
        //     name TEXT,
        //     description TEXT,
        //     category TEXT,
        //     price REAL,
        //     status TEXT,
        //     eventId TEXT,
        //     imageUrl TEXT,
        //     pledgedBy TEXT,
        //     needSync INTEGER DEFAULT 0,
        //     syncAction TEXT,
        //     lastModified INTEGER
        //   )
        // ''');
        log('Database has been upgraded to version $newVersion');
      }
    });
    return myDB;
  }

  Future<void> dropDatabase() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    await deleteDatabase(path);
    log("Old database dropped successfully.");
  }

  // Event functions with sync support
  Future<FbEvent> insertNewEvent(FbEvent event, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    if (event.syncAction != null && event.syncAction == 'draft') {
      event.needSync = 0;
    } else if(needSync) {
      event.needSync = 1;
      event.syncAction = 'insert';
    } else if (!needSync) {
      event.needSync = 0;
      event.syncAction = '';
    }
    event.lastModified = DateTime.now().millisecondsSinceEpoch;
    var eventMap = event.toMap();
    await myData!.insert('events', eventMap);
    return event;
  }

  Future<List<FbEvent>> getUnSyncedEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'events',
      where: 'needSync = ?',
      whereArgs: [1],
    );
    return response.map((e) => FbEvent.fromJson(e)).toList();
  }

  Future<FbEvent> updateEvent(FbEvent updatedEvent,
      {bool needSync = true}) async {
    final db = await myDataBase;
    // get the event from the database
    var oldEvent = (await db!
            .query('events', where: 'id = ?', whereArgs: [updatedEvent.id]))
        .map((e) => FbEvent.fromJson(e))
        .first;
    if (oldEvent.syncAction != 'draft') {
      updatedEvent.needSync = oldEvent.needSync == 1 ? 1 : (needSync ? 1 : 0);
      // this is done because if the user was offline and created an event then update it
      // we need
      updatedEvent.syncAction =
          oldEvent.syncAction == 'insert' ? 'insert' : 'update';
    }

    updatedEvent.lastModified = DateTime.now().millisecondsSinceEpoch;
    var eventMap = updatedEvent.toMap();
    await db.update(
      'events',
      eventMap,
      where: 'id = ?',
      whereArgs: [updatedEvent.id],
    );
    return updatedEvent;
  }

  Future<FbEvent> deleteEventById(String id, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    log("searching for event with id $id in local db");
    var event =
        (await myData!.query('events', where: 'id = ?', whereArgs: [id]))
            .map((e) => FbEvent.fromJson(e))
            .first;
    log("found event with id $id in local db");
    if (needSync) {
      // get the event from the database
      if (event.syncAction == 'insert') {
        // if the event was created offline or draft and not synced yet, just delete it
        await myData.delete('events', where: 'id = ?', whereArgs: [id]);
        return event;
      }
      // Mark for deletion instead of actually deleting
      await myData.update(
        'events',
        {
          'needSync': 1,
          'syncAction': 'delete',
          'lastModified': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      log("marked event with id $id for deletion");
      return event;
    } else {
      await myData.delete('events', where: 'id = ?', whereArgs: [id]);
      // Delete all gifts associated with this event
      await myData.delete('gifts', where: 'eventId = ?', whereArgs: [id]);
      log("deleted event with id from local $id");
      return event;
    }
  }

  // Gift functions with sync support
  Future<Gift> insertNewGift(Gift gift, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    if (gift.syncAction != null && gift.syncAction == 'draft') {
      gift.needSync = 0;
    } else if (needSync){
      gift.needSync = 1;
      gift.syncAction = 'insert';
    }else if (!needSync) {
      gift.needSync = 0;
      gift.syncAction = '';
    }
    gift.lastModified = DateTime.now().millisecondsSinceEpoch;
    var giftMap = gift.toMap();
    await myData!.insert('gifts', giftMap);
    return gift;
  }

  Future<List<Gift>> getUnSyncedGifts() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'needSync = ?',
      whereArgs: [1],
    );
    return response.map((e) => Gift.fromJson(e)).toList();
  }

  Future<Gift> updateGift(Gift gift, {bool needSync = true}) async {
    final db = await myDataBase;
    var oldGift =
        (await db!.query('gifts', where: 'id = ?', whereArgs: [gift.id]))
            .map((e) => Gift.fromJson(e))
            .first;
    if (oldGift.syncAction != 'draft') {
      gift.needSync = oldGift.needSync == 1 ? 1 : (needSync ? 1 : 0);
      if (gift.needSync == 0) {
        gift.syncAction = '';
      } else {
        gift.syncAction = oldGift.syncAction == 'insert' ? 'insert' : 'update';
      }
    }

    gift.lastModified = DateTime.now().millisecondsSinceEpoch;
    var giftMap = gift.toMap();
    await db.update(
      'gifts',
      giftMap,
      where: 'id = ?',
      whereArgs: [gift.id],
    );
    return gift;
  }

  Future<void> deleteGiftById(String id, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    if (needSync) {
      var gift =
          (await myData!.query('gifts', where: 'id = ?', whereArgs: [id]))
              .map((e) => Gift.fromJson(e))
              .first;
      if (gift.syncAction == 'insert') {
        // if the gift was created offline and not synced yet, just delete it
        await myData.delete('gifts', where: 'id = ?', whereArgs: [id]);
        return;
      }

      // Mark for deletion instead of actually deleting
      await myData.update(
        'gifts',
        {
          'needSync': 1,
          'syncAction': 'delete',
          'lastModified': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await myData!.delete('gifts', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> markSynced(String table, String id) async {
    final db = await myDataBase;
    await db!.update(
      table,
      {'needSync': 0, 'syncAction': ''},
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<List<Gift>> getGiftsByEventId(String eventId) async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return response.map((e) => Gift.fromJson(e)).toList();
  }

  Future<List<FbEvent>> getEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query('events');
    return response.map((e) => FbEvent.fromJson(e)).toList();
  }

  Future<Gift> getGiftById(String id) {
    return myDataBase.then((db) async {
      List<Map<String, dynamic>> response = await db!.query(
        'gifts',
        where: 'id = ?',
        whereArgs: [id],
      );
      return Gift.fromJson(response.first);
    });
  }

  Future<List<FbEvent>> getDraftEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'events',
      where: 'syncAction = ?',
      whereArgs: ['draft'],
    );
    return response.map((e) => FbEvent.fromJson(e)).toList();
  }

  Future<List<Gift>> getDraftGiftsByEventId(String eventId) async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'eventId = ? AND syncAction = ?',
      whereArgs: [eventId, 'draft'],
    );
    return response.map((e) => Gift.fromJson(e)).toList();
  }

  Future<FbEvent> publishEvent(FbEvent event) async {
    final db = await myDataBase;
    await db!.update(
      'events',
      {
        'syncAction': 'insert',
        'needSync': 1,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
    // publish the gifts within this event
    var gifts = await getGiftsByEventId(event.id!);
    for (var gift in gifts) {
      await db.update(
          'gifts',
          {
            'syncAction': 'insert',
            'needSync': 1,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [gift.id]);
    }
    event.syncAction = 'insert';
    event.needSync = 1;
    return event;
  }

  Future<Gift> publishGift(Gift gift) async {
    final db = await myDataBase;
    await db!.update(
      'gifts',
      {
        'syncAction': 'insert',
        'needSync': 1,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [gift.id],
    );
    gift.syncAction = 'insert';
    gift.needSync = 1;
    return gift;
  }
  Future<void> deleteAllRows(String table) async {
    Database? myData = await myDataBase;
    await myData!.delete(table);
  }
}
