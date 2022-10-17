import 'package:flutter/material.dart';
import 'package:flutter_db_learning/src/drift/todos.dart';

void main() {
  final database = MyDatabase();

  runApp(MyApp(
    database: database,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.database,
  }) : super(key: key);

  final MyDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // データベースインスタンスを親から子に受け渡す
      home: DriftSample(
        database: database,
      ),
    );
  }
}

class DriftSample extends StatelessWidget {
  const DriftSample({Key? key, required this.database}) : super(key: key);

  final MyDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: database.watchEntries(), // データの取得
                builder:
                    (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => Card(
                      margin: EdgeInsets.all(20),
                      color: Colors.green,
                      child: TextButton(
                        child: Text(
                          snapshot.data![index].content,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          await database.updateTodo(
                            snapshot.data![index],
                            'updated',
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () async {
                        await database.addTodo(
                          'test data',
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      child: const Text('remove'),
                      onPressed: () async {
                        final list = await database.allTodoEntries;
                        if (list.isNotEmpty) {
                          await database.deleteTodo(list[list.length - 1]);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
