// ignore_for_file: file_names
import 'dart:async';

import 'package:Music_Pluse/projectfile/backgroundmusic.dart';
import 'package:Music_Pluse/projectfile/internetmusic.dart';

import 'package:Music_Pluse/projectfile/search.dart';
import 'package:Music_Pluse/projectfile/util/details.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:we_slide/we_slide.dart';
import '../main.dart';
import '../projectfile/profile.dart';

import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class NaviagationBarStatus extends StatefulWidget {
  final Stream<bool> stream;
  // late Details user;
  // Details details;
  NaviagationBarStatus(this.stream, {super.key});

  @override
  State<NaviagationBarStatus> createState() =>
      NaviagationBarStatusState(stream);
}

class NaviagationBarStatusState extends State<NaviagationBarStatus> {
  int myindex = 0;

  late List page;
  bool ab = false;
  Stream<bool> stream;

  NaviagationBarStatusState(
    this.stream,
  );
  @override
  void initState() {
    page = [const InternetMusic(), const Search(), Profile()];
    userdetails();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      stream.listen((event) {
        mysetstate(event);
      });
    });
  }

  late SharedPreferences sp;
  Future<void> userdetails() async {
    sp = await SharedPreferences.getInstance();
  }

  static int id = -1;
  mysetstate(bool a) {
    setState(() {
      ab = a;

      id = InternetMusicState.id;
    });
  }

  static String playing = '0';
  // ignore: prefer_typing_uninitialized_variables
  var a;
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      body: Container(
        child: page[myindex],
      ),
      bottomSheet: Visibility(
        visible: ab,
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<SequenceState?>(
                stream: audioplayer.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];

                  int index = state?.currentIndex != null
                      ? int.parse('${state?.currentIndex}')
                      : -1;

                  if (index == -1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        ab = false;
                      });
                    });
                  }

                  return Container(
                      padding: EdgeInsets.all(0),
                      key: ValueKey(state?.currentIndex),
                      height: 70,
                      color: const Color.fromARGB(255, 57, 39, 136),
                      width: a = MediaQuery.of(context).size.width,
                      child: ListTile(
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return MusicPlayUi(
                                    InternetMusicState.playlist,
                                    InternetMusicState.musicindex,
                                    id,
                                    InternetMusicState.listsong);
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ));
                          });
                        },
                        leading: SizedBox(
                          width: 55,
                          child: CachedNetworkImage(
                            imageUrl: sequence.isNotEmpty
                                ? '${sequence[state!.currentIndex].tag.artUri}'
                                : UrlPage.link +
                                    "music_img/" +
                                    InternetMusicState.listsong[0].img,
                          ),
                        ),
                        title: Container(
                          width: 80,
                          child: sequence.isNotEmpty
                              ? Text(
                                  sequence[index].tag.title,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const Text(
                                  'Title',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                        subtitle: Container(
                          width: 80,
                          child: Text(
                            sequence.isNotEmpty
                                ? sequence[index].tag.artist
                                : 'Artist',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        trailing: Container(
                          width: 140,
                          child: Row(
                            children: [
                              Expanded(
                                child: StreamBuilder<SequenceState?>(
                                  stream: audioplayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    return IconButton(
                                        iconSize: 30.0,
                                        color: Colors.white,
                                        icon: audioplayer.hasPrevious
                                            ? Visibility(
                                                visible:
                                                    audioplayer.hasPrevious,
                                                child:
                                                    Icon(Icons.skip_previous))
                                            : Visibility(
                                                visible:
                                                    audioplayer.hasPrevious,
                                                child:
                                                    Icon(Icons.skip_previous)),
                                        onPressed: () {
                                          audioplayer.hasPrevious
                                              ? audioplayer.seekToPrevious()
                                              : null;
                                        });
                                  },
                                ),
                              ),
                              Expanded(
                                child: StreamBuilder<PlayerState>(
                                  stream: audioplayer.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState =
                                        playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (processingState ==
                                            ProcessingState.loading ||
                                        processingState ==
                                            ProcessingState.buffering) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    } else if (playing != true) {
                                      return IconButton(
                                          icon: const Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          iconSize: 30,
                                          onPressed: () {
                                            audioplayer.play();
                                          });
                                    } else if (processingState !=
                                        ProcessingState.completed) {
                                      return IconButton(
                                        icon: const Icon(Icons.pause,
                                            color: Colors.white),
                                        iconSize: 30.0,
                                        onPressed: audioplayer.pause,
                                      );
                                    } else {
                                      return IconButton(
                                        icon: const Icon(Icons.replay,
                                            color: Colors.white),
                                        iconSize: 30.0,
                                        onPressed: () => audioplayer.seek(
                                            Duration.zero,
                                            index: audioplayer
                                                .effectiveIndices!.first),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: StreamBuilder<SequenceState?>(
                                  stream: audioplayer.sequenceStateStream,
                                  builder: (context, snapshot) {
                                    return IconButton(
                                      iconSize: 30,
                                      color: Colors.white,
                                      icon: audioplayer.hasNext
                                          ? Visibility(
                                              visible: audioplayer.hasNext,
                                              child:
                                                  const Icon(Icons.skip_next))
                                          : Visibility(
                                              visible: audioplayer.hasNext,
                                              child:
                                                  const Icon(Icons.skip_next)),
                                      onPressed: () {
                                        audioplayer.hasNext
                                            ? audioplayer.seekToNext()
                                            : null;
                                      },
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: IconButton(
                                      iconSize: 20,
                                      onPressed: () {
                                        audioplayer.stop();
                                        setState(() {
                                          global.streamController.add(false);
                                        });
                                      },
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: const Color.fromARGB(255, 245, 19, 124),
        height: 70.0,
        animationDuration: const Duration(milliseconds: 400),
        color: Color.fromARGB(255, 15, 12, 164),
        items: const <Widget>[
          Icon(
            Icons.home,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.search_sharp,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            myindex = index;
          });
        },
        letIndexChange: (value) => true,
        index: 0,
      ),
    ));
  }
}
