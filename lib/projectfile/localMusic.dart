// ignore_for_file: file_names

import 'dart:async';

import 'package:Music_Pluse/projectfile/AlbumSong.dart';
import 'package:Music_Pluse/projectfile/Allsongs.dart';

import 'package:Music_Pluse/projectfile/genere.dart';
import 'package:Music_Pluse/projectfile/localmusic1.dart';

import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localartist.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

import 'localmusicsearch.dart';

class LocalMusic extends StatefulWidget {
  Stream<bool> stream;
  LocalMusic(this.stream, {super.key});

  @override
  State<LocalMusic> createState() => LocalMusicState(stream);
}

class LocalMusicState extends State<LocalMusic> with WidgetsBindingObserver {
  Stream<bool> stream;
  LocalMusicState(this.stream);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    global.player1.stop();
    super.dispose();
  }

  int index = 0;

  back() {
    AwesomeDialog(
      context: context,
      animType: AnimType.bottomSlide,
      dismissOnTouchOutside: false,
      btnCancelColor: Colors.grey,
      dialogType: DialogType.warning,
      btnOkColor: Colors.red,
      title: 'Warning',
      desc:
          'If you back the page then your local music player will be stop! You want to back?',
      btnOkOnPress: () {
        global.streamController1.close();
        Navigator.pop(context);
      },
      btnCancelOnPress: () {},
    ).show();
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stream.listen((event) {
        mysetstate(event);
      });
    });

    super.initState();
  }

  mysetstate(e) {
    setState(() {
      check = e;
    });
  }

  static bool check = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.detached) {
      global.player1.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  int beforeid = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => back(),
      child: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Material(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 100,
              leading: IconButton(
                  onPressed: () {
                    back();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              backgroundColor: const Color.fromARGB(255, 57, 39, 136),
              title: const Text(
                'Local Music',
                style: TextStyle(color: Colors.white),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(10),
                child: TabBar(
                  // isScrollable: true,
                  indicatorColor: Colors.red,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      text: 'Music',
                    ),
                    Tab(
                      text: 'Album',
                    ),
                    Tab(
                      text: 'Artist',
                    ),
                    Tab(
                      text: 'Genre',
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: LocalMusicSearchState(),
                      );
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              ],
            ),
            body: TabBarView(children: [
              AllSongs(),
              const AlbumSong(),
              const LocalArtist(),
              Genere(),
            ]),
            bottomNavigationBar: Visibility(
              visible: check,
              child: Container(
                height: 70,
                child: StreamBuilder<SequenceState?>(
                  stream: global.player1.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final sequence = state?.sequence ?? [];

                    int index = state?.currentIndex != null
                        ? int.parse('${state?.currentIndex}')
                        : -1;

                    return Container(
                        padding: EdgeInsets.all(0),
                        key: ValueKey(state?.currentIndex),
                        height: 70,
                        color: const Color.fromARGB(255, 57, 39, 136),
                        width: MediaQuery.of(context).size.width,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              beforeid = int.parse(
                                  sequence[state!.currentIndex].tag.id);
                              DeviceMusicState.beforeid = beforeid;
                              DeviceMusicState.beforeindex = state.currentIndex;
                            });

                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return DeviceMusic(
                                    DeviceMusicState.miniplayermusic,
                                    state!.currentIndex,
                                    global.player1,
                                    beforeid);
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(0.0, 1.0); // Slide from the bottom
                                const end = Offset.zero;
                                const curve =
                                    Curves.easeOut; // Adjust the curve
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
                          leading: SizedBox(
                              width: 55,
                              // height: 100,
                              child: sequence.isNotEmpty
                                  ? QueryArtworkWidget(
                                      artworkBorder: BorderRadius.circular(10),
                                      id: int.parse(
                                          sequence[state!.currentIndex].tag.id),
                                      type: ArtworkType.AUDIO)
                                  : Container()),
                          title: SizedBox(
                            width: 70,
                            height: 20.0,
                            child: sequence.isNotEmpty
                                ? Marquee(
                                    text: sequence[index].tag.title,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    blankSpace: 20.0,
                                    velocity: 100.0,
                                    pauseAfterRound: const Duration(seconds: 1),
                                    startPadding: 0.0,
                                    showFadingOnlyWhenScrolling: true,
                                    accelerationDuration:
                                        const Duration(seconds: 1),
                                    accelerationCurve: Curves.linear,
                                    decelerationDuration:
                                        const Duration(milliseconds: 500),
                                    decelerationCurve: Curves.easeOut,
                                  )
                                : const Text(
                                    'Title',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                          ),
                          subtitle: SizedBox(
                            width: 50,
                            child: Text(
                              sequence.isNotEmpty
                                  ? sequence[index].tag.artist.toString()
                                  : 'Artist',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          trailing: Container(
                            width: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  child: StreamBuilder<SequenceState?>(
                                    stream: global.player1.sequenceStateStream,
                                    builder: (context, snapshot) {
                                      // global.streamController.add(true);
                                      return IconButton(
                                          iconSize: 30.0,
                                          color: Colors.white,
                                          icon: global.player1.hasPrevious
                                              ? Visibility(
                                                  visible: global
                                                      .player1.hasPrevious,
                                                  child:
                                                      Icon(Icons.skip_previous))
                                              : Visibility(
                                                  visible: global
                                                      .player1.hasPrevious,
                                                  child: Icon(
                                                      Icons.skip_previous)),
                                          onPressed: () {
                                            global.player1.hasPrevious
                                                ? global.player1
                                                    .seekToPrevious()
                                                : null;
                                          });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder<PlayerState>(
                                    stream: global.player1.playerStateStream,
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
                                          margin: const EdgeInsets.all(8.0),
                                          width: 40.0,
                                          height: 40.0,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else if (playing != true) {
                                        return IconButton(
                                            icon: const Icon(Icons.play_arrow,
                                                color: Colors.white),
                                            iconSize: 40,
                                            onPressed: () {
                                              global.player1.play();
                                            });
                                      } else if (processingState !=
                                          ProcessingState.completed) {
                                        return IconButton(
                                          icon: const Icon(Icons.pause,
                                              color: Colors.white),
                                          iconSize: 40.0,
                                          onPressed: global.player1.pause,
                                        );
                                      } else {
                                        return IconButton(
                                          icon: const Icon(Icons.replay,
                                              color: Colors.white),
                                          iconSize: 40.0,
                                          onPressed: () => global.player1.seek(
                                              Duration.zero,
                                              index: global.player1
                                                  .effectiveIndices!.first),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder<SequenceState?>(
                                    stream: global.player1.sequenceStateStream,
                                    builder: (context, snapshot) {
                                      return IconButton(
                                        iconSize: 30,
                                        color: Colors.white,
                                        icon: global.player1.hasNext
                                            ? Visibility(
                                                visible: global.player1.hasNext,
                                                child:
                                                    const Icon(Icons.skip_next))
                                            : Visibility(
                                                visible: global.player1.hasNext,
                                                child: const Icon(
                                                    Icons.skip_next)),
                                        onPressed: () {
                                          global.player1.hasNext
                                              ? global.player1.seekToNext()
                                              : null;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
