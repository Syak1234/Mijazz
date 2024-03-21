import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:Music_Pluse/projectfile/AlbumSong.dart';
import 'package:Music_Pluse/projectfile/album.dart';
import 'package:Music_Pluse/projectfile/artistmusic.dart';
import 'package:Music_Pluse/projectfile/localMusic.dart';
import 'package:Music_Pluse/projectfile/util/common.dart';
import 'package:audio_session/audio_session.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class DeviceMusic extends StatefulWidget {
  final int index;
  final List<SongModel> songs;
  final AudioPlayer _player;
  late int id;
  DeviceMusic(this.songs, this.index, this._player, this.id, {Key? key})
      : super(key: key);

  @override
  DeviceMusicState createState() => DeviceMusicState(songs, index, _player);
}

class DeviceMusicState extends State<DeviceMusic> with WidgetsBindingObserver {
  late AudioPlayer _player;
  late List<SongModel> _songs;
  int index;
  static int beforeid = 0;
  static int beforeindex = 0;
  DeviceMusicState(this._songs, this.index, this._player);
  // late SharedPreferences sp;
  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.play();
    _player.playbackEventStream
        .listen((event) {}, onError: (Object e, StackTrace stackTrace) {});
  }

  @override
  void initState() {
    _player.setLoopMode(LoopMode.all);

    timeget();
    // TODO: implement initState
    super.initState();

    if (beforeid == widget.id && beforeindex == widget.index) {
    } else {
      beforeid = widget.id;
      beforeindex = widget.index;
      _init().whenComplete(() => playlist());
    }
  }

  late SharedPreferences sp;

  timeget() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      minutes = sp.getInt('time') ?? 0;
    });
  }

  var t;
  var time;

  static List<SongModel> recentmusic = [];
  play() async {
    global.player1.play();
  }

  Future playlist() async {
    if (_songs.isNotEmpty) {
      sp = await SharedPreferences.getInstance();
      bool suffle = sp.getBool('suffle1') ?? false;
      int loop = sp.getInt('loop1') ?? 0;
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: _songs.map((song) {
            final filePath = song.data;
            return AudioSource.uri(
              Uri.file(filePath),
              tag: MediaItem(
                id: song.id.toString(),
                title: song.title,
                artist: song.artist,
                duration: Duration(milliseconds: song.duration ?? 0),
              ),
            );
          }).toList(),
        ),
        initialIndex: index,
      );
      if (loop == 0) {
        _player.setLoopMode(LoopMode.all);
      } else if (loop == 2) {
        _player.setLoopMode(LoopMode.off);
      } else {
        _player.setLoopMode(LoopMode.one);
      }

      suffle == true ? _player.setShuffleModeEnabled(suffle) : null;
      setState(() {
        miniplayermusic = _songs;
      });

      //
    }
  }

  @override
  void dispose() {
    // _player.dispose();

    super.dispose();
  }

  int minutes = 0;

  Color colortext1 = Colors.grey;
  Color colortext2 = Colors.grey;
  Color colortext3 = Colors.grey;

  TextEditingController t1 = TextEditingController();
  final StreamController<double> _stream = StreamController<double>();

  static List<SongModel> miniplayermusic = [];
  Stream<PositionData> get _positionDataStream =>
      _player.positionStream.map((position) => PositionData(
            position,
            _player.bufferedPosition,
            _player.duration ?? Duration.zero,
          ));
  double _sliderValue = 50.0;
  Future info(SongModel data) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ArtistMusic(data.artist.toString())));
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      label: Text(
                        data.artist.toString(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                        alignment: Alignment.topLeft,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Album(
                                data.album.toString(), data.id, data.artist)));
                      },
                      icon: Icon(
                        Icons.album,
                        color: Colors.white,
                      ),
                      label: Text(
                        data.album.toString(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        global.showSliderDialog(context);
                      },
                      icon: Icon(
                        Icons.timer,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Set sleep timer',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        global.songFileShare(
                            _songs[global.player1.currentIndex!.toInt()].data,
                            context);
                      },
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Share song file',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ],
            ),
          );
        });
  }

  back() {
    global.streamController1.add(true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => back(),
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    global.streamController1.add(true);
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          80,
                        ),
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              global.streamController1.add(true);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        'PLAYING NOW',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          info(_songs[global.player1.currentIndex!.toInt()]);
                        },
                        icon: const Icon(
                          Icons.queue_music_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;

                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox();
                    }
                    final metadata = state!.currentSource!.tag as MediaItem;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  height: 280,
                                  width: 280,
                                  decoration: BoxDecoration(boxShadow: const [
                                    BoxShadow(
                                        color: Colors.pink, blurRadius: 20)
                                  ], borderRadius: BorderRadius.circular(150)),
                                  child: QueryArtworkWidget(
                                      artworkFit: BoxFit.cover,
                                      id: int.parse(metadata.id),
                                      type: ArtworkType.AUDIO),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 20.0,
                              child: Marquee(
                                text: metadata.title,
                                style: const TextStyle(color: Colors.white),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 100.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                showFadingOnlyWhenScrolling: true,
                                accelerationDuration:
                                    const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: Text(metadata.artist ?? 'Unknown',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return Expanded(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // margin: EdgeInsets.symmetric(vertical: 10),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbColor: const Color.fromARGB(255, 44, 33,
                                    243), // Customize the thumb color
                                overlayColor:
                                    const Color.fromARGB(255, 44, 33, 243),
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
                                      ? _player.seek(Duration(
                                          seconds: newPosition.toInt()))
                                      : _player.seek(Duration(seconds: 0));
                                },
                                semanticFormatterCallback: (double value) {
                                  return '${positionData?.position.inSeconds.toString().padLeft(2, '0')} / ${positionData?.bufferedPosition ?? Duration.zero}';
                                },
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: positionData?.position.inSeconds != null
                                    ? Text(
                                        '${positionData?.position.inMinutes.toString().padLeft(2, '0')}:${positionData?.position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        '${Duration.zero.inMinutes.toString().padLeft(2, '0')}:${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: positionData?.duration.inSeconds != null
                                    ? Text(
                                        '${positionData?.duration.inMinutes.toString().padLeft(2, '0')}:${positionData?.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        '${Duration.zero.inMinutes.toString().padLeft(2, '0')}:${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showSliderDialog(
                            context: context,
                            title: "Adjust volume",
                            divisions: 10,
                            min: 0.0,
                            max: 1.0,
                            stream: _player.volumeStream,
                            onChanged: _player.setVolume,
                            valueSuffix: 'X');
                      },
                    ),
                    StreamBuilder<SequenceState?>(
                      stream: _player.sequenceStateStream,
                      builder: (context, snapshot) => IconButton(
                        icon: _player.hasNext
                            ? Visibility(
                                visible: _player.hasPrevious,
                                child: Image.asset(
                                  width: 30,
                                  height: 30,
                                  'asset/img/back.png',
                                  color: Colors.white,
                                ),
                              )
                            : Visibility(
                                visible: _player.hasPrevious,
                                child: Image.asset(
                                  width: 30,
                                  height: 30,
                                  'asset/img/back.png',
                                  color: Colors.white,
                                ),
                              ),
                        onPressed:
                            _player.hasPrevious ? _player.seekToPrevious : null,
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;

                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (minutes != 0 && playing == true) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // controller.start();
                            Timer(Duration(minutes: minutes.toInt()), () {
                              global.player1.stop();
                              minutes = 0;
                              Fluttertoast.showToast(msg: 'Completed');
                            });
                          });
                        }
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 64.0,
                            height: 64.0,
                            child: const CircularProgressIndicator(),
                          );
                        } else if (playing != true) {
                          return Container(
                            child: IconButton(
                              icon: Image.asset(
                                'asset/img/play-button.png',
                                width: 50,
                                height: 50,
                                color: Colors.white,
                              ),
                              iconSize: 64.0,
                              onPressed: () {
                                play();
                              },
                            ),
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return Container(
                            child: IconButton(
                              icon: Image.asset(
                                'asset/img/pause.png',
                                width: 50,
                                height: 50,
                                color: Colors.white,
                              ),
                              iconSize: 64.0,
                              onPressed: _player.pause,
                            ),
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(
                              Icons.replay,
                              color: Colors.white,
                            ),
                            iconSize: 64.0,
                            onPressed: () => _player.seek(Duration.zero,
                                index: _player.effectiveIndices!.first),
                          );
                        }
                      },
                    ),
                    StreamBuilder<SequenceState?>(
                      stream: _player.sequenceStateStream,
                      builder: (context, snapshot) => IconButton(
                        icon: _player.hasNext
                            ? Visibility(
                                visible: _player.hasNext,
                                child: Image.asset(
                                  'asset/img/next.png',
                                  width: 30,
                                  height: 30,
                                  color: Colors.white,
                                ),
                              )
                            : Visibility(
                                visible: _player.hasNext,
                                child: Image.asset(
                                  'asset/img/next.png',
                                  width: 10,
                                  height: 10,
                                  color: Colors.white,
                                ),
                              ),
                        onPressed: _player.hasNext ? _player.seekToNext : null,
                      ),
                    ),
                    StreamBuilder<double>(
                      stream: _player.speedStream,
                      builder: (context, snapshot) => IconButton(
                        icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
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
                            stream: _player.speedStream,
                            onChanged: _player.setSpeed,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      StreamBuilder<LoopMode>(
                        stream: _player.loopModeStream,
                        // initialData: LoopMode.all,
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

                              _player.setLoopMode(cycleModes[
                                  (cycleModes.indexOf(loopMode) + 1) %
                                      cycleModes.length]);
                              sp.setInt('loop1', index);
                              if (index == 0) {
                                Fluttertoast.showToast(msg: 'Loopmode all');
                              } else if (index == 1) {
                                Fluttertoast.showToast(msg: 'Loopmode one');
                              } else {
                                Fluttertoast.showToast(msg: 'Loopmode off');
                              }
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Playlist",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      StreamBuilder<bool>(
                        stream: _player.shuffleModeEnabledStream,
                        builder: (context, snapshot) {
                          final shuffleModeEnabled = snapshot.data ?? false;
                          return IconButton(
                            icon: shuffleModeEnabled
                                ? const Icon(Icons.shuffle,
                                    color: Colors.orange)
                                : const Icon(Icons.shuffle, color: Colors.grey),
                            onPressed: () async {
                              final enable = !shuffleModeEnabled;
                              sp = await SharedPreferences.getInstance();

                              sp.setBool('suffle1', enable);

                              if (enable) {
                                await _player.shuffle();
                              }
                              await _player.setShuffleModeEnabled(enable);
                              Fluttertoast.showToast(
                                  msg: 'Shuffle mode ' + enable.toString());
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
