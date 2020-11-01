import 'package:flutter/material.dart';
import 'package:soundpaddb/Models/collection.dart';
import 'package:soundpaddb/Models/list_of_all_sounds.dart';
import 'package:soundpaddb/Models/sound.dart';
import 'package:soundpaddb/screens/add_sounds_to_collection.dart';

class SoundPad extends StatefulWidget {
  final Collection collection;
  SoundPad({Key key, @required this.collection}) : super(key:key);

  @override
  _SoundPadState createState() => _SoundPadState(collection);
}

class _SoundPadState extends State<SoundPad> {
  var playingColor = Colors.red;
  var loopColor = Colors.blue;

  Collection collection;
  List<Sound> sounds;

  _SoundPadState(this.collection);

  //SoundList soundList = new SoundList();
  void initializeSounds(){
    //get sound IDs from the collection and assign them to sounds list
    sounds = Library.convertStringOfIDsToSounds(collection.soundIDs);
    //load all the sounds
  }


  void _handleTap(Sound sound) {
    setState(() {
      sound.isPlaying = !sound.isPlaying;
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

  void loopSound(Sound sound) {
    setState(() {
      sound.audioCache.loop(sound.fileName);
      sound.isPlaying = true;
      sound.displayColor = loopColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      initializeSounds();
    });
    
    return Scaffold(
      appBar: AppBar(
        title: FlatButton(
          onPressed: (){
            print('title');
            },
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
            crossAxisCount: 4,
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
                            Sound clickedSound = getSoundByName(soundName);
                            loopSound(clickedSound);
                          },
                          child: Image.asset('assets/images/$soundName.png',
                              fit: BoxFit.cover),
                        ),
                      ),
                    ]
                ),
              );
            }).toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddSounds(collection: collection)));
          //cant add two the same sounds
          //a possibility to delete sounds
        },
        child: Icon(
          Icons.add,
          size: 35,
        ),
      ),

    );
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




