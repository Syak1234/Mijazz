import 'package:Music_Pluse/projectfile/aivoice.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'backgroundmusic.dart';

import 'internetmusic.dart';
import 'util/song.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController t1 = TextEditingController();
  InternetMusicState lg = InternetMusicState();
  Color color = Colors.white;

  bool t = false;

  List<Song> trackUrls = [];
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
            id: 'track$i',
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
    }
    setState(() {});
    return playlist;
  }

  void _filterItems(String query) {
    global.search.clear();
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        global.search = List.from(global.songs);
      } else {
        global.search = global.songs
            .where((item) =>
                item.title.toLowerCase().contains(query) ||
                item.album.toLowerCase().contains(query) ||
                item.genre.toLowerCase().contains(query) ||
                item.artist.toLowerCase().contains(query) ||
                item.songLyrics.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        extendBody: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 320,
                        margin: const EdgeInsets.only(top: 50),
                        child: TextFormField(
                          controller: t1,
                          onChanged: (query) {
                            _filterItems(query.trim());
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => const Voice()))
                                      .then((value) {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                                },
                                icon: const Icon(
                                  Icons.mic_rounded,
                                )),
                            filled: true,
                            fillColor: color,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                            prefixIcon: t
                                ? const SizedBox(
                                    width: 1,
                                    height: 1,
                                    child: Center(
                                        child: CircularProgressIndicator()))
                                : const Icon(Icons.search),
                            hintText: 'Music, Artist',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: global.search.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: global.search.length,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 70,
                                child: ListTile(
                                  title: Text(
                                    global.search[index].title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    global.search[index].artist,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.blueGrey),
                                  ),
                                  leading: CachedNetworkImage(
                                    imageUrl:
                                        "${UrlPage.link}music_img/${global.search[index].img}",
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    height: 50,
                                    width: 50,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      InternetMusicState.playlist =
                                          ConcatenatingAudioSource(
                                              children:
                                                  buildPlaylist(global.search));
                                      InternetMusicState.musicindex = index;

                                      InternetMusicState.songclass =
                                          global.search[index];
                                      InternetMusicState.listsong =
                                          global.search;
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
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

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
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No search item found ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                  Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.white,
                                  )
                                ],
                              )
                            ],
                          )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
