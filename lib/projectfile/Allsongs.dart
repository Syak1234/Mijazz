// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'artistmusic.dart';
import 'gobalclass.dart';
import 'internetmusic.dart';
import 'localmusic1.dart';
import 'notification.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});
  @override
  State<AllSongs> createState() => AllSongsState();
}

class AllSongsState extends State<AllSongs> {
  var color = InternetMusicState();
  late SharedPreferences sp;
  static bool hasPermission = false;
  bool t = false;

  OnAudioQuery audioQuery = OnAudioQuery();

  AllSongsState();
  @override
  void initState() {
    Noti.initialize(flutterLocalNotificationsPlugin);
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));

    checkPermission(t).whenComplete(() => initAudioPlayer());
  }

  Future checkPermission(bool retry) async {
    hasPermission = await audioQuery.checkAndRequest(
      retryRequest: true,
    );
    hasPermission ? setState(() {}) : false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  static List<SongModel> songs = [];

  Future initAudioPlayer() async {
    if (hasPermission) {
      songs = await audioQuery.querySongs(
          uriType: UriType.EXTERNAL, sortType: SongSortType.DATE_ADDED);
    } else {
      songs = [];
    }

    setState(() {});
  }

  static Future deleteFile(String filePath) async {
    String location = filePath.substring((filePath.lastIndexOf("/")));
    File file = File("Device storage/Download$location");
    try {
      if (await file.exists()) {
        await file.delete();
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  static Future musicinfo(BuildContext context, SongModel data) async {
    return Get.bottomSheet(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        color: const Color.fromARGB(255, 30, 30, 30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton.icon(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 55, vertical: 10)),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ArtistMusic(data.artist.toString())));
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                label: Text(
                  data.artist.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton.icon(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 55, vertical: 10)),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  // songDetails(
                  //     songs[index]);
                  Navigator.of(context).pop();
                  global.songDetails(data, context);
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                label: const Text(
                  'Song info',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton.icon(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 55, vertical: 10)),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  global.setmusicRigntone(context, data);
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                label: const Text(
                  'Set as rigntone',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton.icon(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 55, vertical: 10)),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  global.songFileShare(data.data, context);
                },
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                label: const Text(
                  'Share song file',
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 21, 21, 21),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.red,
                      ),
                      Text(
                        'Play Songs ${songs.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 5),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: ListTile(
                            textColor: Colors.white,
                            leading: QueryArtworkWidget(
                              id: songs[index].id,
                              type: ArtworkType.AUDIO,
                              artworkFit: BoxFit.cover,
                              nullArtworkWidget: const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  musicinfo(context, songs[index]);
                                },
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                )),
                            title: Text(
                              songs[index].title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            horizontalTitleGap: 13.0,
                            subtitle: Text(
                              '${songs[index].artist}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () async {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return DeviceMusic(songs, index,
                                      global.player1, songs[index].id);
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin =
                                      Offset(0.0, 1.0); // Slide from the bottom
                                  const end = Offset.zero;
                                  const curve =
                                      Curves.easeOut; // Adjust the curve
                                  const duration = Duration(
                                      milliseconds:
                                          1000); // Adjust the duration

                                  var tween =
                                      Tween(begin: begin, end: end).chain(
                                    CurveTween(curve: curve),
                                  );

                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ));
                            },
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
