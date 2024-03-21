import 'package:Music_Pluse/projectfile/Allsongs.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'localmusic1.dart';

import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

// ignore: must_be_immutable
class Album extends StatefulWidget {
  String album;
  dynamic id;
  String? artist;
  Album(this.album, this.id, this.artist, {super.key});

  @override
  State<Album> createState() => _AlbumState(album);
}

class _AlbumState extends State<Album> {
  String album = '';
  _AlbumState(this.album);
  OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> albumSongs = [];

  Future<void> retrieveSongsFromAlbum(String albumName) async {
    List<SongModel> allSongs = await audioQuery.querySongs();
    albumSongs = allSongs.where((song) => song.album == albumName).toList();

    setState(() {});
  }

  @override
  void initState() {
    retrieveSongsFromAlbum(album).whenComplete(() => null);
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
          title: Row(
            children: [
              QueryArtworkWidget(
                artworkBorder: BorderRadius.circular(10),
                id: widget.id,
                type: ArtworkType.ALBUM,
                // artworkColor: Colors.white,
              ),
              SizedBox(
                width: 200,
                child: Text(
                  style: TextStyle(color: Colors.white),
                  ' $album',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: albumSongs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: ListTile(
                    textColor: Colors.white,
                    leading: QueryArtworkWidget(
                      id: albumSongs[index].id,
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
                        albumSongs[index].title,
                        textScaleFactor: 1.1,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    horizontalTitleGap: 13.0,
                    subtitle: Text(
                      '${albumSongs[index].artist}',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          // global.songDetails(albumSongs[index], context);
                          AllSongsState.musicinfo(context, albumSongs[index]);
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        )),
                    onTap: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return DeviceMusic(albumSongs, index, global.player1,
                              albumSongs[index].id);
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
