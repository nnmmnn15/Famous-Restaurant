import 'package:must_eat_place_app/model/category.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';
import 'package:sqflite/sqflite.dart';

class CategoryHandler{
  DatabaseHandler handler = DatabaseHandler();

  Future<int> insertCategory(String category) async {
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into category
        values (?)
      """, [category]
    );
    return result;
  }

  Future<List<Category>> queryCategory() async {
    final Database db = await handler.initializeDB();
    List<Map<String, dynamic>> queryResult = await db.rawQuery(
      """
        select * from category
      """
    ); 
    return queryResult.map((e) => Category.fromMap(e)).toList();
  }
}