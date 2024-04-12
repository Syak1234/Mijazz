import 'package:Music_Pluse/projectfile/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

AudioPlayer audioplayer = AudioPlayer();
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  print('object');
  runApp(
    const GetMaterialApp(
      home: Splash(),
      title: 'Mijazz',
      debugShowCheckedModeBanner: false,
    ),
  );
}
