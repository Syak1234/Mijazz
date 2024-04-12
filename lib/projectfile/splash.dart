import 'dart:async';

import 'dart:ui';

import 'package:animated_background/animated_background.dart';

import 'package:Music_Pluse/projectfile/Navigatorbar.dart';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

import 'interface.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late SharedPreferences sp;

  String u = "";
  String id = '', name = '', email = '', user = '', image = '';
  late bool c;
  Future getId() async {
    sp = await SharedPreferences.getInstance();

    u = sp.getString('email') ?? '';
    c = sp.getBool('color') ?? false;
  }

  @override
  void initState() {
    super.initState();

    if (global.isPlayer == false) {
      audioplayer = AudioPlayer();
      global.isPlayer = true;
    }

    getId().whenComplete(() {
      if (u == "") {
        Timer(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Interface(),
            ),
          );
        });
      } else {
        Timer(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NaviagationBarStatus(global.streamController.stream),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 30.0),
              child: AnimatedBackground(
                behaviour: RandomParticleBehaviour(
                  options: const ParticleOptions(
                    spawnMaxRadius: 40,
                    spawnMinSpeed: 50.00,
                    particleCount: 68,
                    spawnMaxSpeed: 60,
                    minOpacity: 0.3,
                    spawnOpacity: 0.4,
                    baseColor: Color.fromARGB(255, 44, 93, 239),
                  ),
                ),
                vsync: this,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(
                          child: Image.asset(
                        'asset/img/music2.jpg',
                        width: 150,
                        height: 150,
                      )),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Developed By Sayak Mishra",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
