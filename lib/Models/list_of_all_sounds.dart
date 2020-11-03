import 'package:flutter/cupertino.dart';
import 'package:soundpaddb/Models/sound.dart';

class Library{
  static final List<Sound> _allSounds = [
    Sound(0, "wolves"),
    Sound(1, "crowd"),
    Sound(2, "running"),
    Sound(3, "puddles"),
    Sound(4, "tavern"),
    Sound(5, "forest"),
    Sound(6, "gun"),
    Sound(7, "bird"),
    Sound(8, "barking"),
    Sound(9, "cheering"),
    Sound(10, "knock"),
    Sound(11, "lute"),
    Sound(12, "olddoor"),
    Sound(13, "thunderstorm"),
    Sound(14, "whispering"),
  ];

  static List<Sound> getAllSounds (){
    return _allSounds;
  }

  static List<Sound> convertStringOfIDsToSounds(String soundIDs){
    if(soundIDs != ''){
      List<String> idAsString  = soundIDs.split(',');
      List<int> ids = new List(idAsString.length);

      List<Sound> soundpad = new List(idAsString.length);

      for(int i = 0; i< idAsString.length; i++){
        ids[i] = int.parse(idAsString[i]);
        soundpad[i] = _allSounds[ids[i]];
      }

      return soundpad;
    }
    else{
      return new List();
    }
  }

  static List<Sound> getRemainingSoundsFromLibrary(String soundIDs){
    List<Sound> soundsInCollection = convertStringOfIDsToSounds(soundIDs);
    List<Sound> remainingSounds = _allSounds;
    if(soundsInCollection.length > 0){
      for(int i = soundsInCollection.length -1; i >= 0; i--){
        for(int j = remainingSounds.length - 1; j >= 0; j--){
          if(identical(soundsInCollection[i], remainingSounds[j]))
            remainingSounds.removeAt(j);
        }
      }
    }
    return remainingSounds;
  }
}