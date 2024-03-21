import 'package:Music_Pluse/projectfile/Allsongs.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'localMusic.dart';
import 'localmusic1.dart';

import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class ArtistMusic extends StatefulWidget {
  String artist;
  ArtistMusic(this.artist, {super.key});

  @override
  State<ArtistMusic> createState() => ArtistMusicState(artist);
}

class ArtistMusicState extends State<ArtistMusic> {
  String artist = '';

  OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> artistSongs = [];

  ArtistMusicState(this.artist);

  Future<void> retrieveSongsFromAlbum(String artistName) async {
    List<SongModel> allSongs = await audioQuery.querySongs();
    artistSongs = allSongs.where((song) => song.artist == artistName).toList();

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    retrieveSongsFromAlbum(artist).whenComplete(() => null);
    super.initState();
  }

  Future songDetails(SongModel song) async {
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
            ' $artist',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: artistSongs.length,
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
                      id: artistSongs[index].id,
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
                        artistSongs[index].title,
                        textScaleFactor: 1.1,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    horizontalTitleGap: 13.0,
                    subtitle: Text(
                      '${artistSongs[index].artist}',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          AllSongsState.musicinfo(context, artistSongs[index]);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        )),
                    onTap: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return DeviceMusic(artistSongs, index, global.player1,
                              artistSongs[index].id);
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
