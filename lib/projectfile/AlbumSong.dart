import 'package:Music_Pluse/projectfile/album.dart';
import 'package:flutter/material.dart';

import 'package:on_audio_query/on_audio_query.dart';

import 'Allsongs.dart';

class AlbumSong extends StatefulWidget {
  const AlbumSong({super.key});

  @override
  State<AlbumSong> createState() => _AlbumSongState();
}

class _AlbumSongState extends State<AlbumSong> {
  List<AlbumModel> _songs = [];

  OnAudioQuery audioQuery = OnAudioQuery();
  Future initAudioPlayer() async {
    if (AllSongsState.hasPermission)
      _songs = await audioQuery.queryAlbums(uriType: UriType.EXTERNAL);
    else
      _songs = [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initAudioPlayer().whenComplete(() => null);
  }

  Future songDetails(AlbumModel song) async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            'Album Info',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              child: Text('album: ${song.album.toString()}'),
            ),
            SimpleDialogOption(
              child: Text('artist: ${song.artist.toString()}'),
            ),
            SimpleDialogOption(
              child: Text("album id: ${song.id.toString()}"),
            ),
            SimpleDialogOption(
              child: Text("artistId: ${song.artistId.toString()}"),
            ),
            SimpleDialogOption(
              child: Text('album songs : ${song.numOfSongs.toString()}'),
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
                        'Album ${_songs.length}',
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
                            type: ArtworkType.ALBUM,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: const Icon(
                              Icons.music_note_rounded,
                              size: 50,
                              color: Colors.cyan,
                            ),
                          ),
                          title: Text(
                            _songs[index].album,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            onPressed: () => songDetails(_songs[index]),
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            '${_songs[index].artist}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Album(_songs[index].album,
                                    _songs[index].id, _songs[index].artist)));
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
