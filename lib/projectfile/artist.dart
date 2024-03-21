import 'dart:convert';
import 'dart:ui';

import 'package:Music_Pluse/projectfile/util/song.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../main.dart';
import 'backgroundmusic.dart';
import 'internetmusic.dart';

// ignore: must_be_immutable
class Artist extends StatefulWidget {
  String img;
  String name;
  Artist(this.img, this.name, {super.key});

  @override
  State<Artist> createState() => _ArtistState();
}

class _ArtistState extends State<Artist> {
  @override
  void initState() {
    super.initState();
    _filterItems(widget.name).whenComplete(() => buildPlaylist(global.artist));
  }

  Future _filterItems(String name) async {
    setState(() {
      name = name.toLowerCase();
      if (global.songs.isEmpty) {
        global.songs.clear();
      } else {
        global.artist = global.songs
            .where((item) => item.artist.toLowerCase().contains(name))
            .toList();
      }
    });
  }

  int totalduration = 0;
  List<Song> trackUrls = [];
  Duration totalDuration = Duration();
  List<AudioSource> buildPlaylist(song) {
    setState(() {
      trackUrls = song;
    });
    List<AudioSource> playlist = [];
    playlist.clear();

    for (int i = 0; i < trackUrls.length; i++) {
      playlist.add(
        AudioSource.uri(
          Uri.parse(UrlPage.link + trackUrls[i].filePath),
          tag: MediaItem(
            displaySubtitle: trackUrls[i].releasedate,
            id: trackUrls[i].id,
            album: trackUrls[i].album,
            title: trackUrls[i].title,
            artist: trackUrls[i].artist,
            displayDescription: trackUrls[i].filePath,
            displayTitle: trackUrls[i].songLyrics,
            genre: trackUrls[i].genre,
            duration: Duration(minutes: int.parse(trackUrls[i].duration)),
            artUri: Uri.parse("${UrlPage.link}music_img/${trackUrls[i].img}"),
          ),
        ),
      );
      totalduration = totalduration + int.parse(trackUrls[i].duration);
    }
    setState(() {
      InternetMusicState.playlist =
          ConcatenatingAudioSource(children: playlist);
      totalDuration =
          Duration(seconds: totalduration, milliseconds: totalduration);
    });

    return playlist;
  }

  bool play = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        toolbarHeight: 70,
                        centerTitle: true,
                        backgroundColor: Color.fromARGB(255, 45, 8, 212),
                        leading: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_sharp,
                              color: Colors.white,
                            )),
                        expandedHeight: 300.0,
                        pinned: true,
                        flexibleSpace: Stack(
                          children: [
                            Positioned(
                              child: FlexibleSpaceBar(
                                stretchModes: const <StretchMode>[
                                  StretchMode.zoomBackground
                                ],
                                centerTitle: true,
                                titlePadding:
                                    EdgeInsets.only(left: 60, bottom: 10),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.name,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Total Duration: $totalDuration',
                                          style: TextStyle(fontSize: 8),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                background: CachedNetworkImage(
                                  imageUrl: widget.img,
                                  colorBlendMode: BlendMode.color,
                                  color: Color.fromARGB(255, 1, 0, 5),
                                  // Your background image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      global.artist.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, int index) {
                                  return Container(
                                    key: ValueKey(index),
                                    margin: EdgeInsets.symmetric(vertical: 1),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          audioplayer.seek(Duration.zero,
                                              index: index);

                                          InternetMusicState.musicindex = index;

                                          InternetMusicState.songclass =
                                              global.artist[index];
                                          InternetMusicState.listsong =
                                              global.artist;
                                          InternetMusicState.id = int.parse(
                                              InternetMusicState.songclass.id);
                                          InternetMusicState.size = 70;

                                          Navigator.of(context)
                                              .push(PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return MusicPlayUi(
                                                  InternetMusicState.playlist,
                                                  InternetMusicState.musicindex,
                                                  InternetMusicState.id,
                                                  InternetMusicState.listsong);
                                            },
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;
                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              var offsetAnimation =
                                                  animation.drive(tween);

                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                          ));
                                        });
                                      },
                                      textColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: Text(
                                        global.artist[index].title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        global.artist[index].artist,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${UrlPage.link}music_img/${global.artist[index].img}',
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                            ),
                                          )),
                                    ),
                                  );
                                },
                                childCount: global
                                    .artist.length, // Number of list items
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) => Center(
                                        heightFactor: 10,
                                        child: Text(
                                          'No music found ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25),
                                        ),
                                      ),
                                  childCount: 1),
                            )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
