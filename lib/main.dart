import 'package:flutter/material.dart';
import 'package:soundpaddb/Models/collection.dart';
import 'package:soundpaddb/screens/add_sounds_to_collection.dart';
import 'package:soundpaddb/screens/list_of_collections.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: CollectionList(),
      //AddSounds(collection: new Collection.withSounds('test', "")),

        debugShowCheckedModeBanner: false
    );
  }
}
