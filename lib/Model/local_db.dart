import 'package:celebratio/Model/event.dart';
import 'package:celebratio/Model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'gift.dart';

class DataBase {
  static Database? _myDataBase;

  Future<Database?> get myDataBase async {
    if (_myDataBase == null) {
      _myDataBase = await initialize();
      return _myDataBase;
    } else {
      return _myDataBase;
    }
  }

  static const _version = 3;

  initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    Database myDB = await openDatabase(path, version: _version,
        onCreate: (db, version) async {
      // Create Users table
      await db.execute('''CREATE TABLE IF NOT EXISTS users (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL,
          preferences TEXT
      )''');

      // Create Events table with foreign key referencing Users
      await db.execute('''CREATE TABLE IF NOT EXISTS events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT NOT NULL,
          category TEXT NOT NULL,
          userId INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )''');

      // Create Gifts table with foreign key referencing Events
      await db.execute('''CREATE TABLE IF NOT EXISTS gifts (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          status TEXT NOT NULL,
          eventId INTEGER NOT NULL,
          pledgedById INTEGER,
          FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )''');

      // Create Friends table with foreign keys referencing Users
      await db.execute('''CREATE TABLE IF NOT EXISTS friends (
          userId INTEGER NOT NULL,
          friendId INTEGER NOT NULL,
          PRIMARY KEY (userId, friendId),
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (friendId) REFERENCES users (id) ON DELETE CASCADE
      )''');

      print("Database has been created with proper foreign keys.");
    }, onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < newVersion) {
        await db.execute('DROP TABLE IF EXISTS gifts');
        // Create Gifts table with foreign key referencing Events
        await db.execute('''CREATE TABLE IF NOT EXISTS gifts (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          status TEXT NOT NULL,
          eventId INTEGER NOT NULL,
          pledgerId INTEGER,
          FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )''');
        print('Database has been upgraded to version $newVersion');
      }
    });
    return myDB;
  }



  /// Function to drop the database
  Future<void> dropDatabase() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    await deleteDatabase(path);
    print("Old database dropped successfully.");
  }

  // Event functions

  deleteEventById(int id) async {
    Database? myData = await myDataBase;
    int response =
        await myData!.delete('events', where: 'id = ?', whereArgs: [id]);
    return response;
  }

  insertNewEvent(Event eventData) async {
    Database? myData = await myDataBase;
    int response = await myData!.insert('events', eventData.toMap());
    return response;
  }

  getAllEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query('events');
    List<Event> events = response.map((e) => Event.fromJson(e)).toList();
    return events;
  }

  getEventsByUserId(int id) async {
    Database? myData = await myDataBase;
    var response =
        await myData!.query('events', where: 'userId = ?', whereArgs: [id]);
    List<Event> events = response.map((e) => Event.fromJson(e)).toList();
    return events;
  }

  updateEvent(Event event) async {
    final db = await myDataBase;
    await db!.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  getUpcomingEventsCountByUserId(int id) async {
    Database? myData = await myDataBase;
    var response = await myData!.query('events',
        where: 'userId = ? AND date >= ?',
        whereArgs: [id, DateTime.now().toIso8601String()]);
    return response.length;
  }

  // User functions

  insertNewUser(User userData) async {
    Database? myData = await myDataBase;
    int response = await myData!.insert('users', userData.toMap());
    return response;
  }

  getAllUsers() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query('users');
    List<User> users = response.map((e) => User.fromJson(e)).toList();
    return users;
  }

  getUserById(int id) async {
    Database? myData = await myDataBase;
    var response = await myData!.query('users', where: 'id = ?', whereArgs: [id]);
    User user = User.fromJson(response.first);
    return user;
  }

  // Gift functions

  insertNewGift(Gift giftData) async {
    Database? myData = await myDataBase;
    int response = await myData!.insert('gifts', giftData.toMap());
    return response;
  }

  getGiftsByEventId(int id) async {
    Database? myData = await myDataBase;
    var response = await myData!.query('gifts', where: 'eventId = ?', whereArgs: [id]);
    List<Gift> gifts = response.map((e) => Gift.fromJson(e)).toList();
    return gifts;
  }

  deleteGiftById(int id) async {
    Database? myData = await myDataBase;
    int response = await myData!.delete('gifts', where: 'id = ?', whereArgs: [id]);
    return response;
  }

  updateGift(Gift gift) async {
    final db = await myDataBase;
    await db!.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }
}
