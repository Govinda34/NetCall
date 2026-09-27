import '../db/database.dart';

class AppRepo {
  final AppDatabase database = AppDatabase.instance;
  Future<List<Map<String,Object?>>> rows(String table,{String? where,List<Object?>? args,String? order}) async => (await database.db).query(table,where:where,whereArgs:args,orderBy:order);
  Future<int> insert(String table,Map<String,Object?> data) async => (await database.db).insert(table,data);
  Future<int> update(String table,Map<String,Object?> data,String where,List<Object?> args) async => (await database.db).update(table,data,where:where,whereArgs:args);
  Future<int> delete(String table,int id) async => (await database.db).delete(table,where:'id=?',whereArgs:[id]);
  Future<void> raw(String sql) async => (await database.db).execute(sql);
  Future<List<Map<String,Object?>>> query(String sql,[List<Object?>? args]) async => (await database.db).rawQuery(sql,args);
}
