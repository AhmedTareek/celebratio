// import 'package:celebratio/Model/fb_event.dart';
// import 'package:celebratio/Model/fb_gift.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// import 'gift.dart';
// import 'gift_details.dart';
//
// class DataBase {
//   static Database? _myDataBase;
//
//   Future<Database?> get myDataBase async {
//     if (_myDataBase == null) {
//       _myDataBase = await initialize();
//       return _myDataBase;
//     } else {
//       return _myDataBase;
//     }
//   }
//
//
//
//   static const _version = 4;
//
//   initialize() async {
//     String myPath = await getDatabasesPath();
//     String path = join(myPath, 'celebratio.db');
//     Database myDB = await openDatabase(path, version: _version,
//         onCreate: (db, version) async {
//       print("Database has been created with proper foreign keys.");
//     }, onConfigure: (db) async {
//       await db.execute('PRAGMA foreign_keys = ON');
//     }, onUpgrade: (db, oldVersion, newVersion) async {
//       if (oldVersion < newVersion) {
//         dropDatabase();
//         // Create Gifts table with foreign key referencing Events
//         await db.execute('''
//         CREATE TABLE events (
//           id TEXT PRIMARY KEY,
//           name TEXT,
//           description TEXT,
//           date TEXT,
//           location TEXT,
//           category TEXT,
//           createdBy TEXT
//         )
//       ''');
//
//         await db.execute('''
//         CREATE TABLE gifts (
//           id TEXT PRIMARY KEY,
//           name TEXT,
//           description TEXT,
//           category TEXT,
//           price REAL,
//           status TEXT,
//           eventId TEXT,
//           imageUrl TEXT,
//           pledgedBy TEXT,
//           FOREIGN KEY (eventId) REFERENCES events (id)
//         )
//       ''');
//         print('Database has been upgraded to version $newVersion');
//       }
//     });
//     return myDB;
//   }
//
//   /// Function to drop the database
//   Future<void> dropDatabase() async {
//     String myPath = await getDatabasesPath();
//     String path = join(myPath, 'celebratio.db');
//     await deleteDatabase(path);
//     print("Old database dropped successfully.");
//   }
//
//   // Event functions
//
//   deleteEventById(int id) async {
//     Database? myData = await myDataBase;
//     int response =
//         await myData!.delete('events', where: 'id = ?', whereArgs: [id]);
//     return response;
//   }
//
//   insertNewEvent(FbEvent event) async {
//     Database? myData = await myDataBase;
//     int response = await myData!.insert('events', event.toMap());
//     return response;
//   }
//
//   getAllEvents() async {
//     Database? myData = await myDataBase;
//     List<Map<String, dynamic>> response = await myData!.query('events');
//     List<FbEvent> events = response.map((e) => FbEvent.fromJson(e)).toList();
//     return events;
//   }
//
//   updateEvent(FbEvent event) async {
//     final db = await myDataBase;
//     await db!.update(
//       'events',
//       event.toMap(),
//       where: 'id = ?',
//       whereArgs: [event.id],
//     );
//   }
//
//
//   // Gift functions
//
//   insertNewGift(FbGift gift) async {
//     Database? myData = await myDataBase;
//     int response = await myData!.insert('gifts', gift.toMap());
//     return response;
//   }
//
//
//   deleteGiftById(int id) async {
//     Database? myData = await myDataBase;
//     int response =
//         await myData!.delete('gifts', where: 'id = ?', whereArgs: [id]);
//     return response;
//   }
//
//   updateGift(Gift gift) async {
//     final db = await myDataBase;
//     await db!.update(
//       'gifts',
//       gift.toMap(),
//       where: 'id = ?',
//       whereArgs: [gift.id],
//     );
//   }
//
//
// }
import 'package:path/path.dart';
import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
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
        print("Upgrading database from version $oldVersion to $newVersion");
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
        print('Database has been upgraded to version $newVersion');
      }
    });
    return myDB;
  }

  Future<void> dropDatabase() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    await deleteDatabase(path);
    print("Old database dropped successfully.");
  }

  // Event functions with sync support
  Future<FbEvent> insertNewEvent(FbEvent event, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    if (event.syncAction != null && event.syncAction == 'draft') {
      event.needSync = 0;
    } else {
      event.needSync = needSync ? 1 : 0;
      event.syncAction = 'insert';
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
    var event =
        (await myData!.query('events', where: 'id = ?', whereArgs: [id]))
            .map((e) => FbEvent.fromJson(e))
            .first;
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
      return event;
    } else {
      await myData!.delete('events', where: 'id = ?', whereArgs: [id]);
      // Delete all gifts associated with this event
      await myData.delete('gifts', where: 'eventId = ?', whereArgs: [id]);
      return event;
    }
  }

  // Gift functions with sync support
  Future<FbGift> insertNewGift(FbGift gift, {bool needSync = true}) async {
    Database? myData = await myDataBase;
    if (gift.syncAction != null && gift.syncAction == 'draft') {
      gift.needSync = 0;
    } else {
      gift.needSync = needSync ? 1 : 0;
      gift.syncAction = 'insert';
    }
    gift.lastModified = DateTime.now().millisecondsSinceEpoch;
    var giftMap = gift.toMap();
    await myData!.insert('gifts', giftMap);
    return gift;
  }

  Future<List<FbGift>> getUnSyncedGifts() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'needSync = ?',
      whereArgs: [1],
    );
    return response.map((e) => FbGift.fromJson(e)).toList();
  }

  Future<FbGift> updateGift(FbGift gift, {bool needSync = true}) async {
    final db = await myDataBase;
    var oldGift =
        (await db!.query('gifts', where: 'id = ?', whereArgs: [gift.id]))
            .map((e) => FbGift.fromJson(e))
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
              .map((e) => FbGift.fromJson(e))
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

  Future<FbEvent> changeEventId(FbEvent oldEvent, String newId) async {
    // insert the same data of the old event with the new id and delete the old event
    final db = await myDataBase;
    var newEvent = FbEvent(
      id: newId,
      name: oldEvent.name,
      description: oldEvent.description,
      date: oldEvent.date,
      location: oldEvent.location,
      category: oldEvent.category,
      createdBy: oldEvent.createdBy,
      needSync: 1,
      syncAction: 'insert',
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );
    await db!.insert('events', newEvent.toMap());
    // delete the old event
    await db.delete('events', where: 'id = ?', whereArgs: [oldEvent.id]);
    // change any gifts referenced the old id
    await db.update(
      'gifts',
      {'eventId': newId},
      where: 'eventId = ?',
      whereArgs: [oldEvent.id],
    );
    return newEvent;
  }

  Future<FbGift> changeGiftId(FbGift oldGift, String newId) async {
    // insert the same data of the old gift with the new id and delete the old gift
    final db = await myDataBase;
    var newGift = FbGift(
      id: newId,
      eventId: oldGift.eventId,
      name: oldGift.name,
      description: oldGift.description,
      category: oldGift.category,
      price: oldGift.price,
      status: oldGift.status,
      imageUrl: oldGift.imageUrl,
      pledgedBy: oldGift.pledgedBy,
      needSync: 1,
      syncAction: 'insert',
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );
    await db!.insert('gifts', newGift.toMap());
    // delete the old gift
    await db.delete('gifts', where: 'id = ?', whereArgs: [oldGift.id]);
    return newGift;
  }

  Future<List<FbGift>> getGiftsByEventId(String eventId) async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return response.map((e) => FbGift.fromJson(e)).toList();
  }

  Future<List<FbEvent>> getEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query('events');
    return response.map((e) => FbEvent.fromJson(e)).toList();
  }

  Future<FbGift> getGiftById(String id) {
    return myDataBase.then((db) async {
      List<Map<String, dynamic>> response = await db!.query(
        'gifts',
        where: 'id = ?',
        whereArgs: [id],
      );
      return FbGift.fromJson(response.first);
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

  Future<List<FbGift>> getDraftGiftsByEventId(String eventId) async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query(
      'gifts',
      where: 'eventId = ? AND syncAction = ?',
      whereArgs: [eventId, 'draft'],
    );
    return response.map((e) => FbGift.fromJson(e)).toList();
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

  Future<FbGift> publishGift(FbGift gift) async {
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
}
