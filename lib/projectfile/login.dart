import 'dart:async';
import 'dart:convert';
import 'package:Music_Pluse/projectfile/Navigatorbar.dart';
import 'package:Music_Pluse/projectfile/signup.dart';
import 'package:Music_Pluse/projectfile/util/details.dart';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'artistnameupload.dart';
import 'forgotpassword.dart';
import 'internetmusic.dart';
import 'loader.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'musicupload.dart';
// import 'package:flutter/src/widgets/framework.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late SharedPreferences sp;
  late AudioPlayer player;
  InternetMusicState u = InternetMusicState();
  GlobalKey<FormState> gk = GlobalKey();
  bool isvisible = false;
  bool type = true;
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  MaterialStatesController t3 = MaterialStatesController();
  late Details details;
  Future<void> validLogin(String email, String pass) async {
    sp = await SharedPreferences.getInstance();

    Map data = {"email": email, "password": pass};
    if (gk.currentState!.validate()) {
      // print(data);
      // ignore: use_build_context_synchronously
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const LoaderProgress();
          });

      try {
        var response = await http.post(
          Uri.parse("${UrlPage.link}student_login.php"),
          body: data,
        );

        // Fluttertoast.showToast(msg: response.toString());
        var jsondata = jsonDecode(response.body);

        if (jsondata["status"] == "true") {
          // sp.setString("email", jsondata['email']);
          // sp.setString('name', jsondata['name']);
          // sp.setString('id', jsondata["id"]);
          // sp.setString('image', jsondata['image']);
          // sp.setString('user', '0');

          getDetails(email);
          // ignore: use_build_context_synchronously
        } else {
          // ignore: use_build_context_synchronously
          showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  alignment: Alignment.center,
                  elevation: 10,
                  shadowColor: const Color.fromARGB(255, 235, 203, 200),
                  title: const Text("Error"),
                  content: const Text("Wrong e-mail and Password"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              });
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Invalid');
      }
    } else {}
  }

  Future getDetails(String email) async {
    sp = await SharedPreferences.getInstance();
    Map data = {"email": email};
    try {
      var response = await http.post(
        Uri.parse("${UrlPage.link}getdetails.php"),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        details = Details(jsondata['id'], jsondata['name'], jsondata['email'],
            jsondata['image'], '0');
        sp.setString("email", details.email);
        sp.setString('name', details.name);
        sp.setString('id', details.id);

        sp.setString('image', details.image);
        sp.setString('user', details.user);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        player = AudioPlayer();

        // ignore: use_build_context_syncwhronously
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NaviagationBarStatus(global.streamController.stream)));
        Fluttertoast.showToast(msg: 'Login Successfull');
      } else {
        return null;
      }
    } catch (e) {}
  }

  TextEditingController admincon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Material(
        child: Scaffold(
            body: Container(
          padding: const EdgeInsets.only(top: 35),
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: SingleChildScrollView(
            scrollDirection: axisDirectionToAxis(AxisDirection.down),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Form(
                key: gk,
                child: Column(
                  children: [
                    InkWell(
                      onDoubleTap: () {
                        GlobalKey<FormState> gk = GlobalKey();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Enter id'),
                                content: Form(
                                  key: gk,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 3)),
                                        hintText: 'id'),
                                    controller: admincon,
                                    validator: (value) {
                                      if (value == '') {
                                        return 'required';
                                      }
                                    },
                                  ),
                                ),
                                actions: [
                                  FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No')),
                                  FilledButton(
                                      onPressed: () {
                                        if (gk.currentState!.validate()) {
                                          if (admincon.text == '9749') {
                                            admincon.text = '';
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MusicUpload()));
                                            // Fluttertoast.showToast(
                                            //     msg: 'Login Succesfull');
                                          } else if (admincon.text == '7047') {
                                            admincon.text = '';
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ArtisNameUpload()));
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      child: const Text('Ok'))
                                ],
                              );
                            });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, right: 10),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    Image.asset(
                      'asset/img/loginimg.png',
                      width: 300,
                      height: 200,
                      // color: Colors.blue,
                    ),
                    Container(
                      alignment: Alignment.center,

                      // ignore: deprecated_member_use
                      child: ColorizeAnimatedTextKit(
                          text: const [
                            'LOGIN',
                          ],
                          speed: const Duration(
                            milliseconds: 700,
                          ),
                          repeatForever: true,
                          textDirection: TextDirection.rtl,
                          textStyle: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          colors: const [
                            Colors.red,
                            Color.fromARGB(255, 49, 15, 240),
                            Color.fromARGB(248, 207, 247, 4),
                            Colors.red,
                          ]),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: AnimatedTextKit(
                        repeatForever: true,
                        // totalRepeatCount: 5,
                        animatedTexts: [
                          TyperAnimatedText(
                            'Please enter the details belows to continue.',
                            speed: const Duration(milliseconds: 150),
                            textStyle: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: TextFormField(
                        controller: t1,
                        style: TextStyle(color: Colors.black),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Can't be blank";
                          } else if (!GetUtils.isEmail(value)) {
                            // Vibration.vibrate();
                            return 'Please Enter a Valid Email';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.black),
                          // labelStyle: TextStyle(color: Colors.black),
                          // labelText: 'Enter Email',

                          hintText: 'e-mail',
                          fillColor: Colors.grey[150],
                          filled: true,
                          prefixIcon: const Icon(Icons.email),
                          prefixIconColor: Colors.black,
                          contentPadding:
                              const EdgeInsets.only(top: 0, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
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
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 0),
                      child: TextFormField(
                        style: TextStyle(color: Colors.black),
                        controller: t2,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Can't be blank";
                          } else if (t2.text.length <= 3) {
                            //
                            // Vibration.vibrate();
                            return 'Password must be atleast 4 characters';
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: type,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.black),
                          // labelStyle: TextStyle(color: Colors.red),
                          // labelText: 'Enter Password',
                          hintText: 'Enter Password',
                          prefixIconColor: Colors.black,
                          prefixIcon: const Icon(Icons.password_sharp),
                          suffixIcon: TextButton(
                            child: type
                                ? Icon(Icons.visibility_off,
                                    color: Colors.black)
                                : Icon(
                                    Icons.visibility,
                                    color: Colors.black,
                                  ),
                            onPressed: () {
                              setState(() {
                                type = !type;
                              });
                            },
                          ),
                          // suffixIconColor: Colors.black,
                          fillColor: Colors.grey[150],
                          filled: true,
                          contentPadding:
                              const EdgeInsets.only(top: 0, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()));
                          },
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        )),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          await validLogin(t1.text, t2.text);
                        },
                        // ignore: sort_child_properties_last
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.red),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Don't have an account! ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SignUp()));
                            });
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
