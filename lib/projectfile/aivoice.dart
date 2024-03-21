// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'package:speech_to_text/speech_to_text.dart';

class Voice extends StatefulWidget {
  const Voice({super.key});

  @override
  State<Voice> createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _listen().whenComplete(() => Timer(const Duration(seconds: 5), () {
          Navigator.pop(context, {'music': _text});
        }));
  }

  @override
  void dispose() {
    _speech.cancel();

    super.dispose();
  }

  double level = 0.0;
  double minSoundLevel = 70000;
  double maxSoundLevel = -70000;

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    if (mounted) {
      setState(() {
        this.level = level;
      });
    }
  }

  Future _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) {
            print('Speech recognition status: $status');
            // ignore: unrelated_type_equality_checks
            if (status == stt.SpeechErrorListener && mounted) {
              setState(() {
                _isListening = false;
              });
            }
          },
          onError: (error) {
            print('Speech recognition error: $error');
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
            // Fluttertoast.showToast(msg: error.toString());
          },
        );

        if (available) {
          if (mounted) {
            setState(() {
              _isListening = true;
            });
          }
          _speech.listen(
            onSoundLevelChange: soundLevelListener,
            listenMode: ListenMode.confirmation,
            cancelOnError: true,
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _text = result.recognizedWords;
                });

                if (result.finalResult) {
                  _filterItems(_text.trim());
                  _speech.cancel();

                  setState(() {
                    _isListening = false;
                  });
                }
              }
            },
          );

          // ignore: use_build_context_synchronously
          // Navigator.of(context).pop();
        }
        // ignore: empty_catches
      } catch (e) {}
    } else {
      try {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
        _speech.stop();
        Navigator.of(context).pop();
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  void _filterItems(String query) {
    global.search.clear();
    query = query.toLowerCase();
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          global.search.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: const Color.fromARGB(255, 7, 17, 36),
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.fourRotatingDots(
                          color: const Color.fromARGB(255, 33, 240, 243),
                          size: 40,
                        )
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Mijazz',
                          textScaleFactor: 2.5,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Say music name or artist',
                        textScaleFactor: 1.4,
                        style: TextStyle(
                            color: Color.fromARGB(255, 188, 182, 182)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                    child: Stack(
                      children: <Widget>[
                        if (mounted)
                          Positioned.fill(
                            bottom: 10,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: .26,
                                        spreadRadius: level * 1.5,
                                        color: const Color.fromARGB(
                                            255, 145, 181, 234))
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 300)),
                      if (mounted)
                        Text(
                          _text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
      ),
    );
  }
}
