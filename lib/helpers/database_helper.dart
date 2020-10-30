import 'dart:io';

import 'package:flutter_todo_list_sqflite_app/models/task_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //
  static final DatabaseHelper instance = DatabaseHelper._instance();

  //the database we are going to use
  static Database _db;

  //
  DatabaseHelper._instance();

  //our tables
  String taskTable = 'tasktable';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  //get db will create a database if there is no database already created using initdb
  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return db;
  }

  //_initdb will use the path provider package and go to the directory in which the app is running and creates a
  //todo_list.db on that path
  //then it opens the database using the path version and the method _createDb and returns the database
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todo_list.db";
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  //this method is used to create the task table inside the database by executing the 'sql' code
  //it takes the database and version
  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)',
    );
  }

  //this method will return every row inside the table given but they are in a map form not task object form
  //and returns the list of map of rows inside the table
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(taskTable);
    return result;
  }

  //this will take the map form which are returned from the getTaskMapList method and converts each one of them
  //into a task object and stores them into a list of tasks and returns that list
  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    return taskList;
  }

  //thsi method will take a task object then converts it to a map and inserts it into the tasktable
  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(taskTable, task.toMap());
    return result;
  }

  //this method will take a task object then converts it to a map and updates the task at colId = taskbeingUpdatedId
  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      taskTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  //this method will take and id then deletes the task from the tasktable where colId = id being deleted
  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      taskTable,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }
}
