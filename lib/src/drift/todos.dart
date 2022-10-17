import 'dart:io'; //追加
import 'package:drift/drift.dart';
import 'package:drift/native.dart'; //追加
import 'package:path/path.dart' as p; //追加
import 'package:path_provider/path_provider.dart'; //追加

part 'todos.g.dart';

//2
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
}

//データベースクラスの定義。@DriftDatabase(tables: [テーブルクラス名])とアノテーションを追加することで、データベースにテーブルが紐づけられる
@DriftDatabase(tables: [Todos])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection()); //追加

  //5
  @override //追加
  int get schemaVersion => 1; //追加

  Stream<List<Todo>> watchEntries() {
    return (select(todos)).watch();
  }

  Future<List<Todo>> get allTodoEntries => select(todos).get();

/**
 * データの追加処理
 * ntoでデータを追加するテーブルを指定
 * insertでデータクラスであるTodoCompanionを追加する。
 */
  Future<int> addTodo(String content) {
    return into(todos).insert(TodosCompanion(content: Value(content)));
  }

  Future<int> updateTodo(Todo todo, String content) {
    return (update(todos)..where((tbl) => tbl.id.equals(todo.id))).write(
      TodosCompanion(
        content: Value(content),
      ),
    );
  }

  /**
   * データ削除処理
   * delete(todos)でテーブルを指定
   * where以下で引数のTodoインスタンスとidが一致するものを探す
   * 探索で見つかった行をgoで削除実行する
   */
  Future<int> deleteTodo(Todo todo) {
    return (delete(todos)..where((tbl) => tbl.id.equals(todo.id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
