import 'package:Music_Pluse/projectfile/genereMusic.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'Allsongs.dart';

class Genere extends StatefulWidget {
  Genere({super.key});

  @override
  State<Genere> createState() => GenereState();
}

class GenereState extends State<Genere> {
  List<GenreModel> _songs = [];

  OnAudioQuery audioQuery = OnAudioQuery();
  Future initAudioPlayer() async {
    if (AllSongsState.hasPermission)
      _songs = await audioQuery.queryGenres(uriType: UriType.EXTERNAL);
    else
      _songs = [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initAudioPlayer().whenComplete(() => null);
  }

  Future songDetails(GenreModel song) async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Genre Info'),
          children: [
            SimpleDialogOption(
              child: Text('genre: ${song.genre.toString()}'),
            ),
            SimpleDialogOption(
              child: Text("genreId: ${song.id.toString()}"),
            ),
            SimpleDialogOption(
              child: Text('genre songs: ${song.numOfSongs.toString()}'),
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.album,
                        color: Colors.red,
                        // size: 30,
                      ),
                      Text(
                        'Genere ${_songs.length}',
                        // textScaleFactor: 1.5,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: ListTile(
                          textColor: Colors.white,
                          leading: QueryArtworkWidget(
                            id: _songs[index].id,
                            type: ArtworkType.GENRE,
                            artworkFit: BoxFit.cover,

                            // artworkColor: Colors.red,
                            nullArtworkWidget: const Icon(
                              Icons.music_note_rounded,
                              size: 50,
                              color: Colors.cyan,
                            ),
                          ),
                          title: Text(
                            _songs[index].genre,
                            // textScaleFactor: 1.1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                songDetails(_songs[index]);
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              )),
                          // horizontalTitleGap: 13.0,

                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    GenereMusic(_songs[index].genre)));
                          },
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
