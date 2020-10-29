import 'package:flutter/material.dart';
import 'package:soundpaddb/Models/collection.dart';
import 'package:soundpaddb/Models/list_of_all_sounds.dart';
import 'package:soundpaddb/Models/sound.dart';
import 'package:soundpaddb/Utils/database_helper.dart';
import 'package:soundpaddb/screens/collection_detail.dart';

class AddSounds extends StatefulWidget {
  final Collection collection;
  AddSounds({Key key, @required this.collection}) : super(key:key);

  @override
  _AddSoundsState createState() => _AddSoundsState(collection);
}

class _AddSoundsState extends State<AddSounds> {

  Collection collection;
  _AddSoundsState(this.collection);

  DatabaseHelper _databaseHelper = new DatabaseHelper();

  static List<Sound> sounds;

  //elements cannot be appended to this list until isGrowable = false
  List<bool> isSoundSelected;
  int selectedSoundsCounter = 0;

  var playingColor = Colors.red;

  @override
  Widget build(BuildContext context) {


    if(isSoundSelected == null || sounds == null){
      _initializeSounds();
    }

    return Scaffold(
      appBar: AppBar(
          title: FlatButton(
            onPressed: (){print('title');},
            onLongPress: (){
              // make it editable
            },
            child:Text(
              collection.name,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
      ),
      body: Container(
        color: Colors.white30,
        child: GridView.count(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: getSoundNames().map((String soundName) {
              return GridTile(
                child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Container(
                          color: getSoundByName(soundName).displayColor,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: FlatButton(
                          onPressed: () {
                            Sound clickedSound = getSoundByName(
                                soundName);
                            _handleTap(clickedSound);
                          },
                          onLongPress: () {
                            Sound clickedSound = getSoundByName(
                                soundName);
                            _handleTap(clickedSound);
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            child: Image.asset('assets/images/$soundName.jpg',
                            fit: BoxFit.cover),
                          )
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: (){
                            setState(() {
                              // toggle selected sound
                              isSoundSelected[getIndexOfAsound(soundName)] = ! isSoundSelected[getIndexOfAsound(soundName)];
                              selectedSoundsCounter++;
                            });
                          },
                          icon: isSoundSelected[getIndexOfAsound(soundName)] ?
                          Icon(
                              Icons.check_box,
                              color: Color(0xff32a885),
                          ) : Icon(
                            Icons.check_box_outline_blank,
                            color: Color(0xff32a885),
                          )
                        )
                      )
                    ]
                ),
              );
            }).toList()),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
        ),
        onPressed: (){
          setState(() {
            _saveChosenSounds();
          });
        },
      ),

    );
  }

  void _initializeSounds(){
    if(collection.soundIDs != null){
      if(collection.soundIDs.length > 0){
        //convert string of ids to sound objects
        sounds = Library.getRemainingSoundsFromLibrary(collection.soundIDs);
        isSoundSelected = List.filled(sounds.length, false);
        return;
      }
    }
    sounds = Library.getAllSounds();
    isSoundSelected = List.filled(sounds.length, false);
  }

  void _handleTap(Sound sound) {
    setState(() {
      sound.isPlaying = !sound.isPlaying;
      print(sound.isPlaying);
      if (sound.isPlaying) {
        sound.audioCache.play(sound.fileName, volume: 100);
        sound.displayColor = playingColor;
      }
      else {
        sound.audioPlayer.stop();
        sound.displayColor = Colors.black;
      }
    });
  }


  String _getIdsOfSelectedSounds(){
    String soundids = "";
    if(selectedSoundsCounter > 0){
      for(int i = 0; i < sounds.length; i++){
        if(isSoundSelected[i]){
          //add all the selected sounds ids to a string and separate with a comma
          soundids += sounds[i].soundID.toString() + ",";
        }
      }
      //remove the last comma
      soundids = soundids.substring(0,soundids.length - 1);
    }
    return soundids;
  }

  void _saveChosenSounds() async{
    // if the collection's soundIDs field is empty, then overwrite it
    if(collection.soundIDs == null || collection.soundIDs.length < 1){
      collection.soundIDs = _getIdsOfSelectedSounds();
      print('add new sounds');
    }
    //if the collection already contains some sounds, append the newly added to the previous soundId String
    else{
      collection.soundIDs = collection.soundIDs + ',' + _getIdsOfSelectedSounds();
    }

    int result = -1;

    List<String> collectionNames = await _databaseHelper.getAllCollectionNames();
    debugPrint(collectionNames.toString());
    int collectionsCount = collectionNames.length;

     if(collectionNames != null && collectionsCount > 0){
       if(_collectionExistsInDB(collection.name, collectionNames)){
         debugPrint(_collectionExistsInDB(collection.name, collectionNames).toString());
         debugPrint('updating collection');
         result = await _databaseHelper.updateCollection(collection);
       }
       else{
         debugPrint('collection doesnt exist');
         result = await _databaseHelper.insertCollection(collection);
         debugPrint(result.toString());
       }
     }

    if(collection.id != null){
      result = await _databaseHelper.updateCollection(collection);
    }
    //if the collection doesn't exist save it to the db
    else{
      debugPrint('collection doesnt exist');
      result = await _databaseHelper.insertCollection(collection);
      debugPrint(result.toString());
    }

    if(result != 0) print('success');
    else print('failure');
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SoundPad(collection: collection)));
  }

  bool _collectionExistsInDB(String newCollectionName, List<String> collectionNames){
    for (int i =0; i<collectionNames.length; i++){
      if(collectionNames[i] == newCollectionName) return true;
    }
    return false;
  }

  int getIndexOfAsound(String soundname){
    for(int i = 0; i < sounds.length; i++){
      if(sounds[i].soundName == soundname){
        return i;
      }
    }
    return -1;
  }


  Sound getSoundByName(String soundname){
    for(int i = 0; i < sounds.length; i++){
      if(sounds[i].soundName == soundname) return sounds[i];
    }
    return null;
  }

  List<String> getSoundNames(){
    List<String> soundNames = new List();
    for(int i = 0; i < sounds.length; i++){
      soundNames.add(sounds[i].soundName);
    }
    return soundNames;
  }

}
