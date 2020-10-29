import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sound{
  int soundID;
  String soundName;
  String fileName;
  String soundImage;
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  bool isPlaying;
  Color displayColor;

  Sound(int soundID, String soundName){
    this.soundID = soundID;
    this.soundName = soundName;
    this.fileName = soundName + ".wav";
    this.soundImage = soundName + ".jpg";
    this.audioPlayer = new AudioPlayer();
    this.audioCache = new AudioCache(fixedPlayer: audioPlayer);
    this.isPlaying = false;
    this.displayColor = Colors.black;
  }

  bool isSoundPlaying(){
    return isPlaying;
  }

}