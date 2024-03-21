import 'dart:convert';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'internetmusic.dart';
import 'loader.dart';
import 'login.dart';

// ignore: must_be_immutable
class PasswordSet extends StatefulWidget {
  String email = '';
  PasswordSet(this.email, {super.key});

  @override
  State<PasswordSet> createState() => _PasswordSetState(email);
}

class _PasswordSetState extends State<PasswordSet> {
  bool type = false;
  bool type1 = false;
  bool v = false, i = false, x = false, y = false, a = true;

  InternetMusicState u = InternetMusicState();
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  GlobalKey<FormState> gk = GlobalKey();

  _PasswordSetState(this.emailget);

  Future<void> updatePassword(String pass1, String pass2, String email) async {
    Map data = {'email': email, 'password': pass1};
    if (gk.currentState!.validate()) {
      if (pass1 == pass2) {
        showDialog(
            context: context,
            builder: (context) {
              return const LoaderProgress();
            });
        try {
          var res = await http
              .post(Uri.parse(UrlPage.link + 'passwordupdate.php'), body: data);
          var jsondata = jsonDecode(res.body);
          if (jsondata['status'] == true) {
            Navigator.of(context).pop();
            // ignore: use_build_context_synchronously
            AwesomeDialog(
                    context: context,
                    dismissOnTouchOutside: false,
                    title: 'Successful',
                    dialogType: DialogType.success,
                    desc: 'Password Update Successful',
                    btnOkOnPress: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const Login()));
                    },
                    btnOkColor: Colors.green)
                .show();
          } else {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
            // ignore: use_build_context_synchronously
            AwesomeDialog(
                    context: context,
                    dismissOnTouchOutside: false,
                    title: 'Error',
                    dialogType: DialogType.error,
                    desc: 'Inavlid',
                    btnOkOnPress: () {},
                    btnOkColor: Colors.red)
                .show();
          }
        } catch (e) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(msg: 'Password Must be same');
      }
    }
  }

  String emailget = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Card(
                      shadowColor: Colors.black,
                      borderOnForeground: true,
                      elevation: 20,
                      child: Container(
                        color: const Color.fromARGB(255, 7, 17, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        // decoration: BoxDecoration(gradient: u.lg),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.cyan,
                                  size: 60,
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Set Password',
                                  textScaleFactor: 2,
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Enter your original email & new password \nto reset your old password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Form(
                                  key: gk,
                                  child: Flexible(
                                    child: Column(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: InputDecoration(
                                              errorStyle: const TextStyle(
                                                  color: Colors.blue),
                                              hintStyle: TextStyle(color: u.w),
                                              labelStyle: TextStyle(color: u.w),
                                              hintText: emailget,
                                              fillColor: Colors.grey[150],
                                              filled: true,
                                              enabled: false,
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color.fromARGB(
                                                      255,
                                                      5,
                                                      127,
                                                      192,
                                                    ),
                                                    width: 2),
                                              ),
                                              prefixIcon:
                                                  const Icon(Icons.email),
                                              suffixIcon: const Icon(
                                                Icons.check_circle,
                                                color: Colors.greenAccent,
                                              ),
                                              prefixIconColor: Colors.cyan,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 0, left: 10),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
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
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.topLeft,
                                            child: const Row(
                                              children: [
                                                SizedBox(
                                                    child: Text(
                                                  'Email Verified',
                                                  style: TextStyle(
                                                      color: Colors.cyan),
                                                )),
                                                SizedBox(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            style: TextStyle(color: u.w),
                                            controller: t2,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Can't be blank";
                                              } else if (t2.text.length <= 3) {
                                                return 'Password must be atleast 4 digit';
                                              } else {
                                                return null;
                                              }
                                            },
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            obscureText: type,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(color: u.w),
                                              labelStyle: TextStyle(color: u.w),
                                              labelText: 'New Password',
                                              hintText: 'New Password',
                                              prefixIconColor: Colors.cyan,
                                              prefixIcon: const Icon(
                                                  Icons.password_sharp),
                                              suffixIcon: TextButton(
                                                child: type
                                                    ? const Icon(
                                                        Icons.visibility_off,
                                                        color: Colors.blue,
                                                      )
                                                    : const Icon(
                                                        Icons.visibility,
                                                        color: Colors.blue,
                                                      ),
                                                onPressed: () {
                                                  setState(() {
                                                    type = !type;
                                                  });
                                                },
                                              ),
                                              suffixIconColor: u.w,
                                              fillColor: Colors.transparent,
                                              filled: true,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 0, left: 10),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: u.w, width: 2),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
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
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          // width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            style: TextStyle(color: u.w),
                                            controller: t3,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Can't be blank";
                                              } else if (t3.text.length <= 3) {
                                                return 'Password must be atleast 4 digit';
                                              } else {
                                                return null;
                                              }
                                            },
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            obscureText: type1,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(color: u.w),
                                              labelStyle: TextStyle(color: u.w),
                                              labelText: 'Confirm Password',
                                              hintText: 'Confirm Password',
                                              prefixIconColor: Colors.cyan,
                                              prefixIcon: const Icon(
                                                  Icons.password_sharp),
                                              suffixIcon: TextButton(
                                                child: type1
                                                    ? const Icon(
                                                        Icons.visibility_off,
                                                        color: Colors.blue,
                                                      )
                                                    : const Icon(
                                                        Icons.visibility,
                                                        color: Colors.blue,
                                                      ),
                                                onPressed: () {
                                                  setState(() {
                                                    type1 = !type1;
                                                  });
                                                },
                                              ),
                                              suffixIconColor: Colors.white,
                                              fillColor: Colors.transparent,
                                              filled: true,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 0,
                                                      left: 10,
                                                      bottom: 0),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: u.w, width: 2),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
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
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 20, bottom: 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              updatePassword(
                                                  t2.text, t3.text, emailget);
                                            },
                                            // ignore: sort_child_properties_last
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              child: Text(
                                                'SAVE',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateColor
                                                      .resolveWith(
                                                (states) => Colors.cyan,
                                              ),
                                              shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Login()));
                                                },
                                                icon: const Icon(
                                                  Icons.arrow_back_ios,
                                                  color: Colors.white,
                                                ),
                                                label: const Text(
                                                  'Back to Login',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
