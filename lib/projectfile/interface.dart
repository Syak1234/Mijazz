import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'internetmusic.dart';
import 'login.dart';
// import 'package:Mijazee/page/theme.dart';

class Interface extends StatefulWidget {
  const Interface({super.key});

  @override
  State<Interface> createState() => _InterfaceState();
}

class _InterfaceState extends State<Interface> {
  InternetMusicState color = InternetMusicState();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Animate(
            autoPlay: true,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 100),
              color: Colors.black,
              child: Column(
                children: [
                  Animate(
                    autoPlay: true,
                    child: Text(
                      'Mijazz',
                      textScaleFactor: 3,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Bree Serif'),
                    )
                        .animate()
                        .show(delay: 800.ms)
                        .slideX(
                          duration: const Duration(milliseconds: 600),
                        )
                        .shimmer(
                      colors: const [
                        Colors.white,
                        Colors.yellowAccent,
                        Color.fromARGB(255, 49, 183, 228),
                        Colors.white,
                      ],
                      // delay: const Duration(seconds: 2),
                      duration: const Duration(seconds: 2),
                    ).blurred(blur: 0, colorOpacity: 0),
                  ),
                  Animate(
                    autoPlay: true,
                    child: Text(
                      'make your life more live',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'Pacifico'),
                    )
                        .animate()
                        .show(delay: 1000.ms)
                        .slideX(duration: 600.ms)
                        .shimmer(
                            color: Colors.yellow,
                            delay: 2000.ms,
                            duration: const Duration(seconds: 2))
                        .blurred(blur: 0, colorOpacity: 0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        });
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 34),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.red,
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(color: Colors.white),
                      ),
                    ).animate()
                      ..show(delay: 1500.ms)
                      ..slideX(duration: 600.ms)
                      ..blurred(blur: 0, colorOpacity: 0),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 350,
                    child: Animate(
                      autoPlay: true,
                      child: Image.asset(
                        'asset/img/female1.png',
                        fit: BoxFit.fitHeight,
                        // height: MediaQuery.of(context).size.height,
                      ).animate()
                        ..show(delay: 2000.ms)
                        ..slideX(

                                // delay: Duration(seconds: 5),
                                duration: const Duration(milliseconds: 600))
                            .blurred(blur: 0, colorOpacity: 0),
                    ),
                  ),
                ],
              ),
            ).animate().slideX().shimmer(
                color: const Color.fromARGB(255, 189, 236, 19),
                // color: Color.fromARGB(255, 244, 136, 86),
                angle: 30,
                blendMode: BlendMode.colorBurn,
                duration: 2000.ms),
          ),
        ),
      ),
    );
  }
}
