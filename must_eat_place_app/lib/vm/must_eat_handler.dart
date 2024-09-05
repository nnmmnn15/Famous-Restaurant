import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';
import 'package:sqflite/sqflite.dart';

class MustEatHandler {
  DatabaseHandler handler = DatabaseHandler();

  Future<int> insertMustEat(MustEat mustEat) async {
    int result = 0;
    final Database db = await handler.initializeDB();

    result = await db.rawInsert("""
      insert into must_eat(image, lat, long, name, tel, review, category, score)
      values (?, ?, ?, ?, ?, ?, ?, ?)
      """, [
      mustEat.image,
      mustEat.lat,
      mustEat.long,
      mustEat.name,
      mustEat.tel,
      mustEat.review,
      mustEat.category,
      mustEat.score,
    ]);

    return result;
  }

  Future<List<MustEat>> queryMustEat(String orderBy) async {
    String query = '';
    if(orderBy == '이름순'){
      query = "SELECT * FROM must_eat ORDER BY name";
    } else if (orderBy == '점수 높은 순'){
      query = "SELECT * FROM must_eat ORDER BY score Desc, name";
    } else {
      query = "SELECT * FROM must_eat ORDER BY score, name";
    }
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(query);
    return queryResult.map((e) => MustEat.fromMap(e)).toList();
  }

  Future<List<MustEat>> queryCategoryMustEat(String category, String orderBy) async {
    String query = '';
    if(orderBy == '이름순'){
      query = "SELECT * FROM must_eat WHERE category = ? ORDER BY name";
    } else if (orderBy == '점수 높은 순'){
      query = "SELECT * FROM must_eat WHERE category = ? ORDER BY score Desc, name";
    } else {
      query = "SELECT * FROM must_eat WHERE category = ? ORDER BY score, name";
    }
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(query,[category]);
    return queryResult.map((e) => MustEat.fromMap(e)).toList();
  }

  Future<int> deleteMustEat(int? seq) async {
    final Database db = await handler.initializeDB();
    final int queryResult = await db.rawDelete('''
          DELETE FROM
              must_eat
          WHERE
              seq = ?
          ''', [seq]);
    return queryResult;
  }

  Future<int> updateMustEat(MustEat mustEat) async {
    int result = 0;
    final Database db = await handler.initializeDB();

    result = await db.rawUpdate("""
      UPDATE must_eat 
      SET image = ?, lat = ?, long = ?, name = ?, tel = ?, review = ?, category = ?, score = ?
      WHERE seq = ?
      """, [
      mustEat.image,
      mustEat.lat,
      mustEat.long,
      mustEat.name,
      mustEat.tel,
      mustEat.review,
      mustEat.category,
      mustEat.score,
      mustEat.seq,
    ]);

    return result;
  }
}
