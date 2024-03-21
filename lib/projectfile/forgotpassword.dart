import 'dart:convert';

import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:email_otp/email_otp.dart';

// import 'details.dart';
import 'internetmusic.dart';
import 'loader.dart';
import 'login.dart';
import 'otp.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  EmailOTP otp = EmailOTP();
  InternetMusicState c = InternetMusicState();
  TextEditingController t1 = TextEditingController();
  GlobalKey<FormState> gk = GlobalKey();

  // get emailAuth => null;

  // get remoteServerConfiguration => null;
  // void verify() {
  //   print(emailAuth.validateOtp(
  //       recipientMail: _emailcontroller.value.text,
  //       userOtp: _otpcontroller.value.text));
  // }

  Future<void> check(String id) async {
    Map data = {'id': id};
    if (gk.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const LoaderProgress();
          });
      try {
        var res = await http
            .post(Uri.parse(UrlPage.link + 'forgotpassword.php'), body: data);
        var jsondata = jsonDecode(res.body);
        if (jsondata['status'] == true) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          final email = jsondata['email'];
          // ignore: use_build_context_synchronously
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => OTP(email)));
        } else {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          // ignore: use_build_context_synchronously
          AwesomeDialog(
                  context: context,
                  dismissOnTouchOutside: false,
                  title: 'Error',
                  dialogType: DialogType.error,
                  desc: 'User-id Not Found',
                  btnOkOnPress: () {},
                  btnOkColor: Colors.red)
              .show();
        }
      } catch (e) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: e.toString());
      }
    } else {
      Fluttertoast.showToast(msg: 'Invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                transform: Matrix4.rotationZ(200),
                child: const Icon(
                  Icons.key,
                  color: Color.fromARGB(255, 99, 14, 228),
                  fill: 0.9,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Forgot Password",
                textScaleFactor: 2,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "No Worries, we'll send you reset instructions",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          Form(
            key: gk,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: t1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Cannot blank';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Enter Your User-id",
                      labelText: "Enter User id",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      check(t1.text);
                    },
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 95, vertical: 15)),
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 99, 14, 228))),
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Back to log in",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          )
        ],
      ),
    )));
  }
}
