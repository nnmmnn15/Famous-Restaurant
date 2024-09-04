import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler{
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'mustEat.db'),
      onCreate: (db, version) async {
        await db.execute("""
            create table must_eat
            (
              seq integer primary key autoincrement,
              image blob,
              lat real,
              long real,
              name text,
              tel text,
              review text
            )
        """);
      },
      version: 1,
    );
  }
}