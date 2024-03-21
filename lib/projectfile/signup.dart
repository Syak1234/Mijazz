import 'dart:convert';

import 'package:Music_Pluse/projectfile/util/details.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Navigatorbar.dart';

import 'internetmusic.dart';
import 'loader.dart';
import 'login.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  InternetMusicState color = InternetMusicState();
  late SharedPreferences sp;
  bool a = false, b = false;
  GlobalKey<FormState> gk = GlobalKey();
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  TextEditingController t4 = TextEditingController();
  late Details details;
  Future<void> validateCheck(
      String name, String email, String pass1, String pass2) async {
    sp = await SharedPreferences.getInstance();
    Map data = {"email": email, "password": pass1.toString(), "name": name};

    if (gk.currentState!.validate() && pass1 == pass2) {
      showDialog(
          context: context,
          builder: (context) {
            return const LoaderProgress();
          });
      var response = await http
          .post(Uri.parse(UrlPage.link + "student_signup.php"), body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata["status"] == true) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        AwesomeDialog(
          context: context,
          animType: AnimType.bottomSlide,
          dismissOnTouchOutside: false,
          dialogType: DialogType.error,
          btnOkColor: Colors.red,
          title: 'Error',
          desc: jsondata['msg'].toString(),
          btnOkOnPress: () {},
        ).show();
      }
    } else if (gk.currentState!.validate() && pass1 != pass2) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        context: context,
        animType: AnimType.bottomSlide,
        dismissOnTouchOutside: true,
        dialogType: DialogType.warning,
        btnOkColor: Colors.red,
        title: 'warning',
        desc: 'Password must be same',
        btnOkOnPress: () {},
      ).show();
    }
  }

  GoogleSignInAccount? currentUser;
  Future<void> _handleSignIn() async {
    var img = '';
    try {
      sp = await SharedPreferences.getInstance();

      currentUser = await GoogleSignIn().signIn();

      Navigator.pop(context);
      if (currentUser.toString().isNotEmpty) {
        if (currentUser!.photoUrl != null) {
          img = currentUser!.photoUrl.toString();
        } else {
          img = '';
        }
        details = Details('Google user', currentUser!.displayName.toString(),
            currentUser!.email.toString(), img, '1');
        sp.setString("email", details.email);
        sp.setString('name', details.name);
        sp.setString('id', details.id);

        sp.setString('image', details.image);
        sp.setString('user', details.user);
        audioplayer = AudioPlayer();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NaviagationBarStatus(global.streamController.stream)));
        Fluttertoast.showToast(msg: 'Login Successfull');
      } else {}
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
              key: gk,
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 0),
                        child: Row(
                          children: [
                            Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                height: 80,
                                width: 80,
                                child: const Image(
                                    image: AssetImage('asset/img/music.jpg'))),
                            Container(
                              alignment: Alignment.center,
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  TypewriterAnimatedText('Mijazz',
                                      textStyle: TextStyle(
                                          fontSize: 25, color: Colors.white),
                                      speed: const Duration(milliseconds: 150),
                                      curve: Curves.bounceIn),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 99, 193, 222),
                          shape: BoxShape.circle,
                        ),
                        height: 150,
                        child: Image.asset(
                          'asset/img/loginimg.png',
                          // scale: 1,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Create Account',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'Already have account? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            InkWell(
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const Login()));
                              },
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 3),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (t1.text.isEmpty) {
                              return "Can't be blank";
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          controller: t1,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: const Icon(
                              Icons.person,
                            ),
                            hintStyle: TextStyle(color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIconColor: Colors.white,
                            hintText: 'Enter Full Name',
                            labelText: 'Enter Full Name',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(
                                    255,
                                    5,
                                    127,
                                    192,
                                  ),
                                  width: 2),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (t2.text.isEmpty) {
                              return "Can't be blank";
                            } else if (!GetUtils.isEmail(value!)) {
                              return 'Please Enter a Valid Email';
                            } else {
                              return null;
                            }
                          },
                          controller: t2,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: const Icon(Icons.email),
                            prefixIconColor: Colors.white,
                            hintText: 'e-mail',
                            labelText: 'Email Address',
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(
                                    255,
                                    5,
                                    127,
                                    192,
                                  ),
                                  width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          obscureText: a,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Can't be blank";
                            } else if (value.length <= 3) {
                              return "Password must be greater than 3";
                            } else {
                              return null;
                            }
                          },
                          controller: t3,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: const Icon(Icons.password),
                            labelText: 'Password',
                            hintText: 'Password',
                            prefixIconColor: Colors.white,
                            suffixIcon: TextButton(
                              child: a
                                  ? Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                              onPressed: () {
                                setState(() {
                                  a = !a;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(
                                    255,
                                    5,
                                    127,
                                    192,
                                  ),
                                  width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Can't be blank";
                            } else if (value.length <= 3) {
                              return "Password must be greater than 3";
                            } else {
                              return null;
                            }
                          },
                          controller: t4,
                          obscureText: b,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: const Icon(Icons.password),
                            suffixIcon: TextButton(
                              onPressed: () {
                                setState(() {
                                  b = !b;
                                });
                              },
                              child: b
                                  ? Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                            ),
                            hintText: 'Confirm Password',
                            labelText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIconColor: Colors.white,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                  255,
                                  5,
                                  127,
                                  192,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Divider(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.red)),
                          onPressed: () {
                            setState(() {
                              validateCheck(t1.text, t2.text, t3.text, t4.text);

                              //
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'sign up'.toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          child: const Text.rich(
                            TextSpan(
                              text: 'By Singing up you agree to our terms\n',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Conditions & Privacy Policy.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        height: 30,
                        child: const Text(
                          'Or',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SizedBox(

                            //   width: 150,
                            //   height: 100,
                            //   child: Column(
                            //     children: [
                            //       IconButton(
                            //         onPressed: () {},
                            //         icon: Image.asset(
                            //           'asset/img/facebook.png',
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),

                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _handleSignIn();
                                      },
                                      icon: Image.asset(
                                        'asset/img/google.png',
                                      ))
                                ],
                              ),
                            )
                          ]),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
