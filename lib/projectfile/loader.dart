import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoaderProgress extends StatefulWidget {
  const LoaderProgress({super.key});

  @override
  State<LoaderProgress> createState() => _LoaderProgressState();
}

class _LoaderProgressState extends State<LoaderProgress> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // color: ThemeDataColor.t ? Colors.black : Colors.transparent,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.blueAccent, size: 70),
                  const Text(
                    "Loading....",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
