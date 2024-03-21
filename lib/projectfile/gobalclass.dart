// ignore: library_names
library Music_Pluse.gobalclass;

import 'dart:async';
import 'dart:io';
import 'package:Music_Pluse/projectfile/util/artistclass.dart';
import 'package:Music_Pluse/projectfile/util/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:ringtone_set/ringtone_set.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();
StreamController<bool> streamController1 = StreamController<bool>.broadcast();
StreamController<bool> streamController2 = StreamController<bool>.broadcast();
List<Song> songs = [];
List<ArtistClass> artistdetails = [];
List<Song> artist = [];
List<Song> search = [];
List<Song> bengali = [];
List<Song> hollywood = [];
List<Song> panjabi = [];
List<Song> bollywood = [];
List<Song> recentmusic = [];
List albumsong = [];
List<SongModel> localmusic = [];
List<Song> favorites = [];

AudioPlayer player1 = AudioPlayer();
bool isPlayer = false;

// late StreamController<SequenceState?> sequenceStateController;
// late StreamController<PositionData> positionDataController;
// // late StreamController<bool> shuffleModeEnabledStream;
// late StreamController<LoopMode> loopModeStream;
// late StreamController<double> speedStream;
// late StreamController<PlayerState> playerStateStream;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future songDetails(SongModel song, BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text('Song Info'),
        children: [
          SimpleDialogOption(
            child: Text('title: ${song.title}'),
          ),
          SimpleDialogOption(
            child: Text('album: ${song.album.toString()}'),
          ),
          SimpleDialogOption(
            child: Text('artist: ${song.artist.toString()}'),
          ),
          SimpleDialogOption(
            child: Text('duration: ${song.duration.toString()}'),
          ),
          SimpleDialogOption(
            child: Text('fileExtension: ${song.fileExtension.toString()}'),
          ),
          SimpleDialogOption(
            child: Text('uri: ${song.data.toString()}'),
          ),
          SimpleDialogOption(
            child: Text("genre: ${song.genre.toString()}"),
          ),
          SimpleDialogOption(
            child:
                Text("displayNameWOExt: ${song.displayNameWOExt.toString()}"),
          ),
          SimpleDialogOption(
            child: Text("displayName: ${song.displayName.toString()}"),
          ),
          SimpleDialogOption(
            child: Text("dateAdded: ${song.dateAdded.toString()}"),
          ),
          SimpleDialogOption(
            child: Text("isMusic: ${song.isMusic.toString()}"),
          ),
          SimpleDialogOption(
            child: Text('size: ${song.size.toString()}'),
          ),
          SimpleDialogOption(
            child: Text('artistId: ${song.artistId.toString()}'),
          ),
        ],
      );
    },
  );
}

Future songFileShare(String data, BuildContext context) async {
  try {
    final file = XFile(data);
    Share.shareXFiles(
      [file],
    );
  } catch (e) {}
  Navigator.of(context).pop();
}

OnAudioQuery playlist = OnAudioQuery();
Future setmusicRigntone(BuildContext context, SongModel data) async {
  Navigator.of(context).pop();
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 55, vertical: 18)),
                      alignment: Alignment.center,
                    ),
                    onPressed: () {
                      final File ringtoneFile = File(data.data);
                      RingtoneSet.setRingtoneFromFile(ringtoneFile);
                      Noti.showBigTextNotification(
                          title: data.title,
                          body: 'Rigntone set Successful',
                          fln: flutterLocalNotificationsPlugin);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Set as call rigntone',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 55, vertical: 18)),
                      alignment: Alignment.center,
                    ),
                    onPressed: () {
                      final File ringtoneFile = File(data.data);
                      RingtoneSet.setAlarmFromFile(ringtoneFile);
                      Noti.showBigTextNotification(
                          title: data.title,
                          body: 'Alarm set Successful',
                          fln: flutterLocalNotificationsPlugin);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Set as alarm rigntone',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Divider(
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 55, vertical: 18)),
                      alignment: Alignment.center,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
            ],
          ),
        );
      });
}

Color colortext1 = Colors.grey;
Color colortext2 = Colors.grey;
Color colortext3 = Colors.grey;
int minutes = 0;
late SharedPreferences sp;
void showSliderDialog(BuildContext context) async {
  sp = await SharedPreferences.getInstance();
  minutes = sp.getInt('time') ?? 0;
  if (minutes == 30) {
    colortext1 = Colors.red;
  } else {
    colortext1 = Colors.grey;
  }
  if (minutes == 60) {
    colortext2 = Colors.red;
  } else {
    colortext2 = Colors.grey;
  }
  if (minutes == 90) {
    colortext3 = Colors.red;
  } else {
    colortext3 = Colors.grey;
  }
  double trackhight = 4;
  // ignore: use_build_context_synchronously
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            color: Colors.grey.shade900,
            height: 200,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                    const Text(
                      'Set sleep timer',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                        onPressed: () {
                          sp.setInt('time', minutes);
                          minutes = sp.getInt('time')!.toInt();
                          Navigator.pop(context);

                          minutes != 0
                              ? Fluttertoast.showToast(
                                  msg: 'Stop audio in $minutes min')
                              : Fluttertoast.showToast(msg: 'Sleep timer off');
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        )),
                  ],
                ),
                SizedBox(
                  // height: 150,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          minutes == 0.0
                              ? 'Sleep timer off'
                              : 'Stop audio in $minutes min',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SliderTheme(
                        data: const SliderThemeData(
                          thumbColor: Color.fromARGB(
                              255, 44, 33, 243), // Customize the thumb color
                          overlayColor: Color.fromARGB(255, 44, 33, 243),
                          activeTrackColor: Colors
                              .blue, // Customize the active track (duration) color
                          inactiveTrackColor: Colors.grey,
                        ),
                        child: Slider(
                            max: 90,
                            label: '$minutes',
                            min: 0,
                            divisions: 90,
                            value: minutes.toDouble(),
                            onChanged: (v) {
                              setState(() {
                                minutes = v.toInt();
                                if (minutes == 30) {
                                  colortext1 = Colors.red;
                                } else {
                                  colortext1 = Colors.grey;
                                }
                                if (minutes == 60) {
                                  colortext2 = Colors.red;
                                } else {
                                  colortext2 = Colors.grey;
                                }
                                if (minutes == 90) {
                                  colortext3 = Colors.red;
                                } else {
                                  colortext3 = Colors.grey;
                                }
                              });
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'off',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                '30 min',
                                style: TextStyle(color: colortext1),
                              ),
                              Text(
                                '60 min',
                                style: TextStyle(color: colortext2),
                              ),
                              Text(
                                '90 min',
                                style: TextStyle(color: colortext3),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
