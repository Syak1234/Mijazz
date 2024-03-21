// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:Music_Pluse/projectfile/loader.dart';
import 'package:Music_Pluse/projectfile/util/common.dart';
import 'package:Music_Pluse/projectfile/util/song.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';

import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:just_audio/just_audio.dart';

import 'package:just_audio_background/just_audio_background.dart';
// import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

import 'notification.dart';

// ignore: must_be_immutable
class MusicPlayUi extends StatefulWidget {
  ConcatenatingAudioSource playlist;
  int musicindex;
  int id;
  List<Song> listsong = [];
  MusicPlayUi(this.playlist, this.musicindex, this.id, this.listsong,
      {Key? key})
      : super(key: key);

  @override
  MusicPlayUiState createState() => MusicPlayUiState(playlist);
}

class MusicPlayUiState extends State<MusicPlayUi> with WidgetsBindingObserver {
  late SharedPreferences sp;

  static int i = 0;

  static bool isPlayerInitialized = false;
  ConcatenatingAudioSource playlist;
  MusicPlayUiState(this.playlist);

  static int beforeid = 0;
  static int beforeindex = 0;
  bool check = false;
  @override
  void initState() {
    Noti.initialize(global.flutterLocalNotificationsPlugin);
    super.initState();

    playmusic();
  }

  Future playmusic() async {
    // global.streamController.add(true);
    sp = await SharedPreferences.getInstance();
    setState(() {
      randomNumber = sp.getInt('colorgradient') ?? 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (beforeid == widget.id &&
          beforeindex == widget.musicindex &&
          isPlayerInitialized == true) {
        // audioplayer.play();
      } else {
        isPlayerInitialized = true;

        beforeid = widget.id;
        beforeindex = widget.musicindex;
        _init().whenComplete(() => null);
      }
    });
  }

  @override
  void dispose() {
    global.streamController.add(true);

    super.dispose();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    audioplayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      setState(() async {
        sp = await SharedPreferences.getInstance();
        bool suffle = sp.getBool('suffle') ?? false;
        int loop = sp.getInt('loop') ?? 0;
        await audioplayer
            .setAudioSource(
          playlist,
          preload: true,
          initialIndex: widget.musicindex,
          initialPosition: Duration.zero,
        )
            .whenComplete(() {
          if (loop == 0) {
            audioplayer.setLoopMode(LoopMode.all);
          } else if (loop == 2) {
            audioplayer.setLoopMode(LoopMode.off);
          } else {
            audioplayer.setLoopMode(LoopMode.one);
          }

          suffle == true ? audioplayer.setShuffleModeEnabled(suffle) : null;
          audioplayer.play();
        });
      });
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioplayer.positionStream,
          audioplayer.bufferedPositionStream,
          audioplayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  late MediaItem metadata = MediaItem(id: ' ', title: ' ');
  var filePath;
  bool downloading = false;
  static int downloadvalue = 0;

  checkDownloadfile(musicUrl) async {
    var name = metadata.title;

    showDialog(
        context: context,
        builder: (context) {
          return LoaderProgress();
        });
    try {
      final response = await http.get(Uri.parse(UrlPage.link + musicUrl));

      if (response.statusCode == 200) {
        String filename = name + DateTime.now().microsecond.toString();
        filePath = '/storage/emulated/0/Download/$filename.mp3';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }

        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded Successfully",
            fln: global.flutterLocalNotificationsPlugin);
      } else {
        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded failed",
            fln: global.flutterLocalNotificationsPlugin);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }
      }
    } catch (e) {
      Noti.showBigTextNotification(
          title: "$name",
          body: "Music Downloaded failed",
          fln: global.flutterLocalNotificationsPlugin);
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _requestNotificationPermissions() async {
    final bool? granted = await global.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    if (granted != null && granted) {
    } else {}
  }

  static int index = 0;

  BoxController boxController = BoxController();

  Random random = Random();
  int min = 0;
  int max = 10;

  int randomNumber = 0;
  List listcolor = [
    LinearGradient(
      colors: [Colors.black, Colors.black],
      begin: Alignment.topCenter,
    ),
    LinearGradient(
      colors: [Color.fromARGB(255, 200, 180, 2), Colors.black],
      // tileMode: TileMode.decal,
      begin: Alignment.topCenter,
    ),
    LinearGradient(
        colors: [Color.fromARGB(255, 11, 29, 121), Colors.black],
        begin: Alignment.topCenter),
    LinearGradient(
        colors: [Colors.red, Colors.black], begin: Alignment.topCenter),
  ];

  Widget imageProfile(Song data) {
    setState(() {
      check = widget.listsong[audioplayer.currentIndex!.toInt()].isFavorite;
    });

    return Material(
      child: Container(
        decoration: BoxDecoration(gradient: listcolor[randomNumber]),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 100.0,
            sigmaY: 100.0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<SequenceState?>(
                      stream: audioplayer.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;

                        if (state?.sequence.isEmpty ?? true) {
                          return const SizedBox();
                        }
                        metadata = state?.currentSource!.tag as MediaItem;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Image.network(
                              fit: BoxFit.fill,
                              metadata.artUri.toString(),
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('asset/img/female2.jpg');
                              },
                              width: MediaQuery.of(context).size.width / 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          alignment: Alignment.center,
                          child: Text(
                            metadata.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textHeightBehavior: const TextHeightBehavior(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${metadata.artist}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 17),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        _requestNotificationPermissions().whenComplete(() {
                          setState(() {
                            downloading = true;
                          });
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Allow Music to download this audio file?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: CachedNetworkImage(
                                      imageUrl: metadata.artUri.toString()),
                                  actions: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.red)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Deny')),
                                    ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await await checkDownloadfile(
                                              metadata.displayDescription);
                                        },
                                        child: Text('Allow'))
                                  ],
                                );
                              });
                          ;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.file_download_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          Text(
                            'Download',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        try {
                          Share.share(
                              '${UrlPage.link}${metadata.displayDescription}');
                        } catch (e) {
                          print('Error sharing music file: $e');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          Text(
                            'Music Link Share',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SongInfo(metadata)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.music_note_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          Text(
                            'Details',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 140)),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.redAccent)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int musiccount = 0;
  back() {
    Navigator.pop(context);
  }

  Widget slidingbox() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(gradient: listcolor[randomNumber]),
        child: StreamBuilder<SequenceState?>(
          stream: audioplayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final sequence = state?.sequence ?? [];

            return ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  for (var i = 0; i < sequence.length; i++)
                    Container(
                      key: ValueKey(sequence[i]),
                      color: i == state!.currentIndex
                          ? Color.fromARGB(255, 3, 29, 161).withAlpha(100)
                          : null,
                      child: ListTile(
                        title: Text(
                          sequence[i].tag.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        leading: SizedBox(
                          width: 50,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: '${sequence[i].tag.artUri}',
                            errorWidget: (context, url, error) {
                              return Image.asset('asset/img/female2.jpg');
                            },
                          ),
                        ),
                        trailing: Text(
                          i == state.currentIndex && audioplayer.playing
                              ? 'Playing'
                              : '',
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),
                        onTap: () {
                          audioplayer.seek(Duration.zero, index: i);
                        },
                      ),
                    )
                ]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => back(),
      child: Material(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(gradient: listcolor[randomNumber]),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                80,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    back();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  )),
                            ),
                            const Text(
                              'PLAYING NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  final index = audioplayer.currentIndex
                                          .toString()
                                          .isNotEmpty
                                      ? audioplayer.currentIndex
                                      : widget.musicindex;
                                  showSlidingBox(
                                    context: context,
                                    box: SlidingBox(
                                        color:
                                            Color.fromARGB(255, 58, 180, 213),
                                        maxHeight: 600,
                                        draggableIconVisible: false,
                                        collapsed: true,
                                        backdrop: Backdrop(),
                                        body: imageProfile(
                                            widget.listsong[index!.toInt()])),
                                  );
                                },
                                icon: Image.asset(
                                  'asset/img/240_F_475279151_DvpfLODC9URhzBtQum3QVlnjUgtQD1U8-removebg-preview.png',
                                  color: Colors.white,
                                  width: 50,
                                  height: 50,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        width: 400,
                        height: 380,
                        // color: Colors.red,
                        child: StreamBuilder<SequenceState?>(
                          stream: audioplayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;

                            if (state?.sequence.isEmpty ?? true) {
                              return const SizedBox();
                            }

                            metadata = state?.currentSource!.tag as MediaItem;
                            return Column(
                              // mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300,
                                  height: 300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: metadata.artUri.toString(),
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Text(
                                  metadata.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                Text(
                                  metadata.artist!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Container(
                                  height: 20,
                                  // color: Colors.red,
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbColor: const Color.fromARGB(255, 44,
                                          33, 243), // Customize the thumb color
                                      overlayColor: const Color.fromARGB(
                                          255, 44, 33, 243),
                                      activeTrackColor: Colors
                                          .blue, // Customize the active track (duration) color
                                      inactiveTrackColor: Color.fromARGB(
                                          255,
                                          235,
                                          232,
                                          235), // Customize the inactive track (buffered position) color
                                    ),
                                    child: Slider(
                                      min: 0.0,
                                      max: positionData?.duration.inSeconds
                                              .toDouble() ??
                                          Duration.zero.inSeconds.toDouble(),
                                      divisions: 1000,
                                      label: positionData?.position.inSeconds
                                          .toString()
                                          .padLeft(2, '0'),
                                      value: positionData?.position.inSeconds
                                              .toDouble() ??
                                          Duration.zero.inSeconds.toDouble(),
                                      onChanged: (double newPosition) {
                                        positionData!.duration.inSeconds
                                                .toString()
                                                .isNotEmpty
                                            ? audioplayer.seek(Duration(
                                                seconds: newPosition.toInt()))
                                            : audioplayer
                                                .seek(Duration(seconds: 0));
                                      },
                                      semanticFormatterCallback:
                                          (double value) {
                                        return '${positionData?.position.inSeconds.toString().padLeft(2, '0')} / ${positionData?.bufferedPosition ?? Duration.zero}';
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  // height: 25,
                                  // color: Colors.red,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 25),
                                        child: positionData
                                                    ?.position.inSeconds !=
                                                null
                                            ? Text(
                                                '${positionData?.position.inMinutes.toString().padLeft(2, '0')}:${positionData?.position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                '${Duration.zero.inMinutes.toString().padLeft(2, '0')}:${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: positionData
                                                    ?.duration.inSeconds !=
                                                null
                                            ? Text(
                                                '${positionData?.duration.inMinutes.toString().padLeft(2, '0')}:${positionData?.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                '${Duration.zero.inMinutes.toString().padLeft(2, '0')}:${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  showSliderDialog(
                                    context: context,
                                    title: "Adjust volume",
                                    divisions: 10,
                                    min: 0.0,
                                    max: 1.0,
                                    stream: audioplayer.volumeStream,
                                    onChanged: audioplayer.setVolume,
                                  );
                                });
                              },
                            ),
                            StreamBuilder<SequenceState?>(
                              stream: audioplayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return IconButton(
                                    iconSize: 40,
                                    color: Colors.white,
                                    icon: audioplayer.hasPrevious
                                        ? Visibility(
                                            visible: audioplayer.hasPrevious,
                                            child: Icon(Icons.skip_previous))
                                        : Visibility(
                                            visible: audioplayer.hasPrevious,
                                            child: Icon(Icons.skip_previous)),
                                    onPressed: () async {
                                      sp =
                                          await SharedPreferences.getInstance();
                                      audioplayer.hasPrevious
                                          ? audioplayer.seekToPrevious()
                                          : null;
                                      setState(() {
                                        final i = random.nextInt(max + 1);
                                        i > 3 ? null : randomNumber = i;
                                        if (i < 4) {
                                          sp.setInt(
                                              'colorgradient', randomNumber);
                                        }
                                      });
                                    });
                              },
                            ),
                            StreamBuilder<PlayerState>(
                              stream: audioplayer.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) async {
                                  global.streamController.add(true);
                                });

                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 64.0,
                                    height: 64.0,
                                    child: const CircularProgressIndicator(),
                                  );
                                } else if (playing != true) {
                                  return IconButton(
                                      icon: const Icon(Icons.play_circle,
                                          color: Colors.white),
                                      iconSize: 64.0,
                                      onPressed: () {
                                        audioplayer.play();
                                      });
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return IconButton(
                                    icon: const Icon(Icons.pause_circle_filled,
                                        color: Colors.white),
                                    iconSize: 64.0,
                                    onPressed: audioplayer.pause,
                                  );
                                } else {
                                  return IconButton(
                                    icon: const Icon(Icons.replay,
                                        color: Colors.white),
                                    iconSize: 64.0,
                                    onPressed: () => audioplayer.seek(
                                        Duration.zero,
                                        index: audioplayer
                                            .effectiveIndices!.first),
                                  );
                                }
                              },
                            ),
                            StreamBuilder<SequenceState?>(
                              stream: audioplayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return IconButton(
                                  iconSize: 40,
                                  color: Colors.white,
                                  icon: audioplayer.hasNext
                                      ? Visibility(
                                          visible: audioplayer.hasNext,
                                          child: const Icon(Icons.skip_next))
                                      : Visibility(
                                          visible: audioplayer.hasNext,
                                          child: const Icon(Icons.skip_next)),
                                  onPressed: () async {
                                    sp = await SharedPreferences.getInstance();
                                    audioplayer.hasNext
                                        ? audioplayer.seekToNext()
                                        : null;
                                    setState(() {
                                      final i = random.nextInt(max + 1);
                                      i > 3 ? null : randomNumber = i;
                                      if (i < 4) {
                                        sp.setInt(
                                            'colorgradient', randomNumber);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                            StreamBuilder<double>(
                              stream: audioplayer.speedStream,
                              builder: (context, snapshot) => IconButton(
                                icon: Text(
                                    "${snapshot.data?.toStringAsFixed(1)}x",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                onPressed: () {
                                  showSliderDialog(
                                    context: context,
                                    title: "Adjust speed",
                                    divisions: 10,
                                    min: 0.5,
                                    max: 1.5,
                                    stream: audioplayer.speedStream,
                                    onChanged: audioplayer.setSpeed,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          StreamBuilder<LoopMode>(
                            stream: audioplayer.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data ?? LoopMode.off;

                              const icons = [
                                Icon(Icons.repeat, color: Colors.orange),
                                Icon(Icons.repeat, color: Colors.grey),
                                Icon(Icons.repeat_one, color: Colors.orange),
                              ];
                              const cycleModes = [
                                LoopMode.off,
                                LoopMode.all,
                                LoopMode.one,
                              ];
                              final index = cycleModes.indexOf(loopMode);
                              return IconButton(
                                icon: icons[index],
                                onPressed: () async {
                                  sp = await SharedPreferences.getInstance();
                                  audioplayer.setLoopMode(cycleModes[
                                      (cycleModes.indexOf(loopMode) + 1) %
                                          cycleModes.length]);
                                  sp.setInt('loop', index);
                                  if (index == 0) {
                                    Fluttertoast.showToast(msg: 'Loopmode all');
                                  } else if (index == 1)
                                    Fluttertoast.showToast(msg: 'Loopmode one');
                                  else
                                    Fluttertoast.showToast(msg: 'Loopmode off');
                                },
                              );
                            },
                          ),
                          Expanded(
                            child: Text(
                              "Playlist",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: audioplayer.shuffleModeEnabledStream,
                            builder: (context, snapshot) {
                              final shuffleModeEnabled = snapshot.data ?? false;
                              return IconButton(
                                icon: shuffleModeEnabled
                                    ? const Icon(Icons.shuffle,
                                        color: Colors.orange)
                                    : const Icon(Icons.shuffle,
                                        color: Colors.grey),
                                onPressed: () async {
                                  sp = await SharedPreferences.getInstance();
                                  final enable = !shuffleModeEnabled;
                                  sp.setBool('suffle', enable);
                                  if (enable) {
                                    await audioplayer.shuffle();
                                  }

                                  await audioplayer
                                      .setShuffleModeEnabled(enable);
                                  Fluttertoast.showToast(
                                      msg: 'Shuffle mode ' + enable.toString());
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomSheet: Container(
            decoration: BoxDecoration(
              gradient: listcolor[randomNumber],
            ),
            width: MediaQuery.of(context).size.width,
            child: IconButton(
                onPressed: () {
                  showSlidingBox(
                      context: context,
                      box: SlidingBox(
                        physics: AlwaysScrollableScrollPhysics(),
                        maxHeight: MediaQuery.of(context).size.height - 100,
                        controller: boxController,
                        draggable: true,
                        color: Colors.black,
                        body: slidingbox(),
                        draggableIconVisible: false,
                      ));
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SongInfo extends StatefulWidget {
  MediaItem metadata;
  SongInfo(this.metadata, {super.key});

  @override
  State<SongInfo> createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  List artistname = [];
  late SharedPreferences sp;

  String filePath = '';
  static int downloadvalue = 0;
  bool downloading = false;

  Future checkDownloadfile(musicUrl) async {
    var name = widget.metadata.title;

    try {
      // MusicPlayUiState.showBeautifulLoadingDialog(context);

      showDialog(
          context: context,
          builder: (context) {
            return LoaderProgress();
          });

      final response = await http.get(Uri.parse(UrlPage.link + musicUrl));

      if (response.statusCode == 200) {
        String filename = name + DateTime.now().microsecond.toString();
        filePath = '/storage/emulated/0/Download/$filename.mp3';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }

        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded Successfully",
            fln: global.flutterLocalNotificationsPlugin);
      } else {
        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded failed",
            fln: global.flutterLocalNotificationsPlugin);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }
      }
    } catch (e) {
      Noti.showBigTextNotification(
          title: "$name",
          body: "Music Downloaded failed",
          fln: global.flutterLocalNotificationsPlugin);
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
    Navigator.pop(context);
  }

  Future<void> _requestNotificationPermissions() async {
    final bool? granted = await global.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    if (granted != null && granted) {
    } else {}
  }

  String lan = '';
  @override
  void initState() {
    String? a = widget.metadata.artist!.endsWith(',')
        ? widget.metadata.artist!.replaceRange(
            widget.metadata.artist!.length - 1,
            widget.metadata.artist!.length,
            '')
        : widget.metadata.artist;

    artistname = a!.split(',');
    if (a.contains('&')) artistname = a.split('&');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 39, 30, 30),
          title: const Text('Song info'),
          actions: [
            IconButton(
                onPressed: () {
                  _requestNotificationPermissions().whenComplete(() {
                    setState(() {
                      downloading = true;
                    });
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Allow Music to download this audio file?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: CachedNetworkImage(
                                imageUrl: widget.metadata.artUri.toString()),
                            actions: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.red)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Deny')),
                              ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await checkDownloadfile(
                                        widget.metadata.displayDescription);
                                  },
                                  child: Text('Allow'))
                            ],
                          );
                        });
                  });
                },
                icon: Icon(Icons.download_rounded))
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: ListTile(
                leading: CachedNetworkImage(
                    imageUrl: widget.metadata.artUri.toString()),
                title: Text(
                  widget.metadata.title,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  widget.metadata.artist.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              )),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'SINGER(S)',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (int i = 0; i < artistname.length; i++)
                            Column(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.person_2_sharp),
                                ),
                                Text(
                                  artistname[i],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          // Column(
                          //   children: [
                          //     CircleAvatar(
                          //       radius: 40,
                          //     ),
                          //     Text(
                          //       'cfb',
                          //       style: TextStyle(color: Colors.white),
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: ListTile(
                        leading: Text(
                          'OTHER DETAILS',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        leading: SizedBox(
                          width: 120,
                          child: Text(
                            'Realeased On',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          widget.metadata.displaySubtitle.toString(),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        leading: SizedBox(
                          width: 120,
                          child: Text(
                            'Duration',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '${Duration(seconds: widget.metadata.duration!.inMinutes.toInt())}',

                          // '${widget.metadata.duration!.inMinutes.toString().padLeft(2, '0')}:${widget.metadata.duration!.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                          // widget.metadata.duration.toString(),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        leading: SizedBox(
                          width: 120,
                          child: Text(
                            'Genre',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          widget.metadata.genre.toString().toLowerCase(),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        leading: SizedBox(
                          width: 120,
                          child: Text(
                            'Album/Movie',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          widget.metadata.album!.isNotEmpty
                              ? widget.metadata.album.toString()
                              : 'None',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: MaterialButton(
                        color: Color.fromARGB(255, 30, 19, 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Material(
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                body: SingleChildScrollView(
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.metadata.displayTitle.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            'Lyrics',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // child:
          //  Padding(
          //   padding: const EdgeInsets.all(15.0),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             '',
          //             style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.bold),
          //           )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           Text(
          //             'Title: ',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           Text(
          //             textAlign: TextAlign.center,
          //             '${metadata.title}',
          //             style: TextStyle(
          //                 color: Colors.cyanAccent,
          //                 // fontSize: ,
          //                 overflow: TextOverflow.ellipsis),
          //           )
          //         ],
          //       ),
          //       Flexible(
          //         child: Row(
          //           children: [
          //             Text(
          //               'Lyrics: ',
          //               style: TextStyle(
          //                   fontSize: 18,
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold),
          //             ),
          // Expanded(
          //   child: Container(
          //     // color: Colors.red,
          //     width: 250,

          //     child: Flexible(
          //       child: ReadMoreText(
          //         style: TextStyle(
          //           color: Colors.cyanAccent,
          //           // fontSize: 12,
          //         ),
          //         '${metadata.displayTitle}',
          //         textAlign: TextAlign.justify,
          //         trimLines: 2,
          //         colorClickableText: Colors.pink,
          //         trimMode: TrimMode.Line,
          //         trimCollapsedText: 'Show more',
          //         trimExpandedText: 'Show less',
          //         moreStyle: const TextStyle(
          //             color: Colors.red,
          //             fontSize: 14,
          //             fontWeight: FontWeight.bold),
          //       ),
          //       // child: Text(
          //       //   ,

          //       //   style: TextStyle(
          //       //     color: Colors.cyanAccent,
          //       //   ),
          //       //   // overflow: TextOverflow.fade,
          //       //   textAlign: TextAlign.justify,
          //       //   // maxLines: 1,
          //       // ),
          //     ),
          //   ),
          // )
          //     ],
          //   ),
          // ),
          //       Row(
          //         children: [
          //           const Text(
          //             'Release Date: ',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           Container(
          //             // width: 190,
          //             child: Text(
          //               '${metadata.displaySubtitle}',
          //               textAlign: TextAlign.center,
          //               style: const TextStyle(
          //                   color: Colors.cyanAccent,
          //                   // fontSize: 20,
          //                   overflow: TextOverflow.ellipsis),
          //             ),
          //           )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text(
          //             'Album:',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           metadata.album!.isNotEmpty
          //               ? Text(
          //                   '${metadata.album}:',
          //                   style: const TextStyle(
          //                       color: Colors.cyanAccent,
          //                       // fontSize: 20,
          //                       overflow: TextOverflow.ellipsis),
          //                 )
          //               : const Text(
          //                   'None',
          //                   style: TextStyle(
          //                       color: Colors.cyanAccent,
          //                       // fontSize: 20,
          //                       overflow: TextOverflow.ellipsis),
          //                 )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text(
          //             'Genre: ',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           Text(
          //             '${metadata.genre}',
          //             textAlign: TextAlign.center,
          //             style: const TextStyle(
          //                 color: Colors.cyanAccent,
          //                 // fontSize: 20,
          //                 overflow: TextOverflow.ellipsis),
          //           )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text(
          //             'Artist: ',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           Text(
          //             '${metadata.artist}',
          //             textAlign: TextAlign.center,
          //             style: const TextStyle(
          //                 color: Colors.cyanAccent,
          //                 // fontSize: 20,
          //                 overflow: TextOverflow.ellipsis),
          //           )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text(
          //             'Duration: ',
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //           metadata.duration?.inMinutes != null
          //               ? Text(
          //                   '${metadata.duration?.inHours} minutes and ${metadata.duration?.inMinutes.remainder(60).toString().padLeft(2, '0')} seconds',
          //                   textAlign: TextAlign.center,
          //                   style: TextStyle(color: Colors.cyanAccent),
          //                 )
          //               : const Text('None',
          //                   textAlign: TextAlign.center,
          //                   style: TextStyle(color: Colors.white)),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
