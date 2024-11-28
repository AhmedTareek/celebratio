import 'package:celebratio/EventData.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  static const _version = 1;

  initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'celebratio.db');
    Database myDB = await openDatabase(path, version: _version,
        onCreate: (db, version) async {
      db.execute('''CREATE TABLE IF NOT EXISTS 'events' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'name' TEXT NOT NULL,
      'description' TEXT NOT NULL,
      'date' TEXT NOT NULL,
      'location' TEXT NOT NULL,
      'category' TEXT NOT NULL)  
      ''');
      print("Database has been created .......");
    });
    return myDB;
  }


  deleteEventById(int id) async {
    Database? myData = await myDataBase;
    int response = await myData!.delete('events', where: 'id = ?', whereArgs: [id]);
    return response;
  }

  insertNewEvent(EventData eventData) async {
    Database? myData = await myDataBase;
    int response = await myData!.insert('events', eventData.toMap());
    return response;
  }

  getAllEvents() async {
    Database? myData = await myDataBase;
    List<Map<String, dynamic>> response = await myData!.query('events');
    List<EventData> events = response.map((e) => EventData.fromJson(e)).toList();
    return events;
  }

  Future<void> updateEvent(EventData event) async {
    final db = await myDataBase;
    await db!.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

}
