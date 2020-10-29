

import 'package:flutter/cupertino.dart';
import 'package:soundpaddb/Models/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';


class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database _database;                // Singleton Database

  String _databaseName = 'test3.db';

  String collectionsTable = 'test3_table';
  String columnName = 'name';
  String columnSoundIDs = 'soundIDs';

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future <Database> get database async{
    if(_database != null){
      return _database;
    }
    _database = await initializeDatabase();
    return _database;

  }

  Future <Database> initializeDatabase() async{
    // get the app's documents directory path to store the db in
    debugPrint('initializing db');
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _databaseName);

    //open/create the database at a given path
    var collectionsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return collectionsDatabase;
  }

  void _createDb(Database db, int version) async {
    print('create db');
    await db.execute('''CREATE TABLE $collectionsTable(
    $columnName TEXT PRIMARY KEY NOT NULL,
    $columnSoundIDs TEXT)''');
  }

  // Fetch operation: get all maps from the database
  // each Collection is stored as a map of key-value pairs, every map in the list
  // (List<Map<String, dynamic>>) carries information about one Collection (because
  //SQFlite uses maps to get and save data to the db)

  Future <List<Map<String, dynamic>>> getCollectionMapList() async{
    Database db = await this.database;
    // you can use raw query - there you need to write the SQL statement yourself
    //query method has many more optional parameters
    var result = await db.query(_databaseHelper.collectionsTable);
    return result;
  }

  //get the List<Map> (from the db) and convert it to List<Collection> (to be used in the ui)
  Future <List<Collection>> getCollectionList()async{
    //the function returns a list of maps(each carries info about a note object
    var collectionMapList = await getCollectionMapList();
    //the number of maps (collection objects)
    int count = collectionMapList.length;

    List<Collection> allCollections = List<Collection> ();

    for(int i = 0; i < count; i++){
      //add collections one by one, converting them from maps to objects
      allCollections.add(Collection.fromMap(collectionMapList[i]));
    }

    return allCollections;
  }

  Future<List<String>> getAllCollectionNames() async{
    List<Collection> allCollections = await getCollectionList();
    List<String> collectionNames = new List();
    for(int i = 0; i< allCollections.length; i++){
      collectionNames.add(allCollections[i].name);
    }
    return collectionNames;
  }

  //Insert operation: insert collection object to the database
  Future<int> insertCollection(Collection collection) async{
    Database db = await this.database;
    var result = await db.insert(collectionsTable, collection.toMap());
    return result;
  }

  //Update: update a collection object and save it to the database
  Future<int> updateCollection(Collection collection) async{
    var db = await this.database;
    print("updateCollection: ");
    print(db);
    var result = await db.update(collectionsTable, collection.toMap(),
        where: '$columnName = ?', whereArgs: [collection.name]);
    return result;
  }

  //Delete operation:
  Future<int> deleteNode(String name) async{
    Database db = await this.database;
    int result = await db.delete(collectionsTable, where: '$columnName = ?', whereArgs: [name]);
    return result;
  }

  //get the number of collections in database
  Future<int> getNumberOfCollections() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $collectionsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}