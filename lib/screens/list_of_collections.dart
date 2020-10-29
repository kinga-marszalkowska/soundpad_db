import 'package:flutter/material.dart';
import 'package:soundpaddb/Models/collection.dart';
import 'package:soundpaddb/Utils/database_helper.dart';
import 'package:soundpaddb/screens/add_sounds_to_collection.dart';
import 'package:soundpaddb/screens/collection_detail.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

class CollectionList extends StatefulWidget {
  @override
  _CollectionListState createState() => _CollectionListState();
}

class _CollectionListState extends State<CollectionList> {
  List<Collection> collections;
  List<String> collectionNames;
  int collectionsCount;
  TextEditingController newCollectionNameTextEditingController = new TextEditingController();

  Collection newCollection = new Collection.withSounds('', '');

  DatabaseHelper _databaseHelper = DatabaseHelper();

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    if(collections == null){
      collections = List<Collection>();
      updateListView();
    }


    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){
              setState(() {});
            },
          )
        ],
        title: Text(
            'All collections',
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text('Your collections:'),
          ),
          Flexible(child:
            getListOfCollections()
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showAlertToCreateNewCollection();
        },
        child: Icon(
            Icons.add,
          size: 35,
        ),
      ),
    );
  }

  ListView getListOfCollections(){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: collectionsCount,
      itemBuilder: (BuildContext context, int index){
        return Card(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              this.collections[index].name,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            subtitle: Text(this.collections[index].soundIDs),
            trailing: FlatButton(
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: (){
                  setState(() {
                    _delete(context, collections[index]);

                  });
                }
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SoundPad(collection: collections[index])),
              );
              debugPrint('list tile touched');
            },
          ),
        );
      },
    );
  }

  void updateListView(){
    final Future <Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Collection>> noteListFuture = _databaseHelper.getCollectionList();
      noteListFuture.then((collectionList){
        setState(() {
          this.collections = collectionList;
          this.collectionsCount = collectionList.length;
          this.collectionNames = _getCollectionNames();
        });
      });
    });
  }

  void showAlertToCreateNewCollection(){
    Alert(
      context: context,
      content: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              autovalidate: false,
              autofocus: true,
              controller: newCollectionNameTextEditingController,
              onChanged: (value){
                debugPrint(value);
                updateName();
              },
              validator: (value){
                if(value.isEmpty){
                  return 'Input the name';
                }
                else if(! _isValidCollectionName(value)){
                  return 'Choose a different name';
                }
                else{
                  return null;
                }
              },
              decoration: new InputDecoration(
              hintText: 'eg. Soundpad1'),
            ),
          ),
          SizedBox(height: 20),
          Text(
              'Click create and add some sounds',
            style: TextStyle(
              color: Colors.grey[300],
            ),
          )

        ],
      ),
      title: "Name your collection: ",
      buttons: [
        DialogButton(
          child: Text(
            "Create!",
            style: TextStyle(color: Colors.grey[850], fontSize: 20),
          ),

          onPressed: () {
            if (_formKey.currentState.validate()) {
              setState(() {
                newCollectionNameTextEditingController.clear();
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddSounds(collection: newCollection)),
                );
                //_saveCollectionToDB(newCollection);
              });
            }
          },
          width: MediaQuery.of(context).size.width * 0.6,
        )
      ],
    ).show();
  }

  void updateName(){
    setState(() {
      this.newCollection.name = newCollectionNameTextEditingController.text;
    });

  }

//  _saveCollectionToDB(Collection collection) async {
//    int result = await _databaseHelper.insertCollection(collection);
//    if(result != 0) {
//      print('success');
//      Navigator.push(context,
//        MaterialPageRoute(builder: (context) => AddSounds(collection: newCollection)),
//      );
//    }
//    else print('could not insert the collection');
//  }

  void _delete(BuildContext context, Collection collection) async{
    int result = await _databaseHelper.deleteNode(collection.name);
    if(result != 0){
      _showSnackBar(context, 'Collection deleted successfully');
      updateListView();
    }
  }

  _showSnackBar(BuildContext context, String message){
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  List<String> _getCollectionNames(){
    List<String> names = new List();
    if(collections != null && collectionsCount > 0){
      collections.forEach((collection) => names.add(collection.name));
    }
    return names;
  }

  // checks if the name is not equal to the one already existing in the DB
  bool _isValidCollectionName(String newCollectionName){
    for (int i =0; i<collectionNames.length; i++){
      if(collectionNames[i] == newCollectionName) return false;
    }
    return true;
  }
}
