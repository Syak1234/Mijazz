import 'package:Music_Pluse/projectfile/Allsongs.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'localMusic.dart';
import 'localmusic1.dart';

import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class GenereMusic extends StatefulWidget {
  String genre;
  GenereMusic(this.genre, {super.key});

  @override
  State<GenereMusic> createState() => GenereMusicState(genre);
}

class GenereMusicState extends State<GenereMusic> {
  String genere = '';

  OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> GenereSongs = [];

  GenereMusicState(this.genere);

  Future<void> retrieveSongsFromAlbum(String genereName) async {
    List<SongModel> allSongs = await audioQuery.querySongs();
    GenereSongs = allSongs.where((song) => song.genre == genereName).toList();

    setState(() {});
  }

  @override
  void initState() {
    retrieveSongsFromAlbum(genere).whenComplete(() => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 21, 21, 21),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          backgroundColor: const Color.fromARGB(255, 57, 39, 136),
          title: Text(
            style: TextStyle(color: Colors.white),
            ' $genere',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: GenereSongs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: ListTile(
                    textColor: Colors.white,
                    leading: QueryArtworkWidget(
                      id: GenereSongs[index].id,
                      type: ArtworkType.AUDIO,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.cyan,
                      ),
                    ),
                    title: SizedBox(
                      width: 50,
                      child: Text(
                        GenereSongs[index].title,
                        textScaleFactor: 1.1,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    horizontalTitleGap: 13.0,
                    subtitle: Text(
                      '${GenereSongs[index].artist}',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          AllSongsState.musicinfo(context, GenereSongs[index]);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        )),
                    onTap: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return DeviceMusic(GenereSongs, index, global.player1,
                              GenereSongs[index].id);
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin =
                              Offset(0.0, 1.0); // Slide from the bottom
                          const end = Offset.zero;
                          const curve = Curves.easeOut; // Adjust the curve
                          const duration = Duration(
                              milliseconds: 1000); // Adjust the duration

                          var tween = Tween(begin: begin, end: end).chain(
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
              }),
        ),
      ),
    );
  }
}
