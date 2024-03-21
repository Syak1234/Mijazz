import 'dart:async';
import 'package:Music_Pluse/projectfile/setpassword.dart';
// import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:custom_timer/custom_timer.dart';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'internetmusic.dart';
import 'loader.dart';

class OTP extends StatefulWidget {
  String email = '';
  OTP(this.email, {super.key});

  @override
  State<OTP> createState() => _OTPState(email);
}

class _OTPState extends State<OTP> with TickerProviderStateMixin {
  // OtpTimerButtonController resendOTP = OtpTimerButtonController();
  String email = '';
  late CustomTimerController controller = CustomTimerController(
    vsync: this,
    begin: const Duration(minutes: 2),
    end: const Duration(seconds: 0),
    initialState: CustomTimerState.reset,
  );
  EmailOTP otp = EmailOTP();
  String verificationCode = '';

  _OTPState(this.email);

  @override
  void dispose() {
    controller.pause();
    controller.reset();
    controller.dispose();
    super.dispose();
  }

  requestOtp() async {
    // resendOTP.loading();
    await sendOtp();
    // resendOTP.startTimer();
  }

  Future sendOtp() async {
    otp.setConfig(
      appEmail: 'sayakmishra27@gmail.com',
      userEmail: email,
      appName: 'Mijazz',
      otpLength: 4,
      otpType: OTPType.digitsOnly,
    );

    if (await otp.sendOTP() == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP has been sent"),
      ));
      controller.start();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Oops, OTP send failed"),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    sendOtp().whenComplete(() => null);
  }

  void otpVerify(String x) async {
    try {
      if (await otp.verifyOTP(otp: x)) {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) {
              return const LoaderProgress();
            });
        Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PasswordSet(email)));
        });
      } else {
        Fluttertoast.showToast(msg: 'Invalid OTP');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  TextEditingController t4 = TextEditingController();
  InternetMusicState c = InternetMusicState();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          backgroundColor: Colors.black,
          title: Text(
            'Verify Email',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          actions: [
            Container(
                padding: const EdgeInsets.only(right: 15),
                alignment: Alignment.center,
                child: CustomTimer(
                    controller: controller,
                    builder: (state, time) {
                      return Text(
                        '${time.minutes}:${time.seconds}s',
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.white),
                      );
                    })),
          ],
          // centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
            child: Column(children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    decoration: const BoxDecoration(
                      // borderRadius: BorderRadius.all(
                      //   Radius.circular(10),
                      // ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'asset/img/R.png',
                        width: 100,
                        height: 100,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                ),
                child: Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10)),
                    Text(
                      'Verification Code',
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  ],
                ),
              ),
              const Row(
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                  Text(
                    'Please enter verification code \nsent to your email',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OtpTextField(
                      numberOfFields: 4,
                      fieldWidth: 50,
                      textStyle: TextStyle(color: Colors.white),
                      focusedBorderColor: Colors.white,
                      enabledBorderColor: Colors.white,
                      disabledBorderColor: Colors.red,
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      mainAxisAlignment: MainAxisAlignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      borderColor: Colors.red,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {},
                      onSubmit: (v) {
                        verificationCode = v;

                        otpVerify(verificationCode);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 30, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 0),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                      // controller: resendOTP,
                      onPressed: () {
                        requestOtp();
                        controller.reset();
                      },
                      // text:
                      // duration: 15,
                      // backgroundColor: Colors.red,
                      child: const Text(
                        'RESEND OTP',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        otpVerify(verificationCode);
                      },
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red),
                        padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                        ),
                      ),
                      child: Text(
                        'VERIFY',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
