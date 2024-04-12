import 'dart:async';
import 'dart:convert';

import 'dart:io' show File;
import 'dart:ui';
import 'package:Music_Pluse/projectfile/artistnameupload.dart';
import 'package:Music_Pluse/projectfile/splash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'backgroundmusic.dart';

import 'forgotpassword.dart';

import 'internetmusic.dart';
import 'loader.dart';

import 'package:image_picker/image_picker.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;
import 'util/webUrl.dart';

class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late SharedPreferences sp;
  File? image;
  bool imageupload = false;
  TextEditingController field = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  String i = '';
  @override
  void initState() {
    x().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  // ignore: prefer_typing_uninitialized_variables
  var name;
  // ignore: prefer_typing_uninitialized_variables
  var id;
  String userno = '';

  Future x() async {
    sp = await SharedPreferences.getInstance();
    i = sp.getString('image') ?? '';

    userno = sp.getString('user') ?? '';
    if (userno != '' && userno == '0') {
      final profileimg = sp.getString('image') ?? '';

      i = "${UrlPage.link}profile_img/$profileimg";

      id = sp.getString('id') ?? '';
    } else if (userno != '' && userno == '1') {
      i = sp.getString('image') ?? '';

      id = sp.getString('id');
      isButtonEnabled = false;
    }

    name = sp.getString('name') ?? '';
    email = sp.getString('email') ?? '';
  }

  File? fileImage;
  InternetMusicState c = InternetMusicState();
  bool t = false;
  Future imageUpload(File imageFile, String id) async {
    sp = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoaderProgress();
      },
    );

    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse('${UrlPage.link}profile_image.php'));
      request.files.add(http.MultipartFile.fromBytes(
          'image', imageFile.readAsBytesSync(),
          filename: imageFile.path.split("/").last));
      var id = sp.getString('id') ?? Null;
      request.fields['id'] = '$id';

      var response = await request.send();

      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);
      if (jsondata['status'] == 'true') {
        sp.setString('image', jsondata['imgtitle']);

        setState(() {
          i = "${UrlPage.link}profile_img/" + jsondata['imgtitle'];
        });
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: jsondata['msg'],
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: jsondata['msg'],
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        msg: e.toString(),
      );
    }
  }

  String email = '';

  File? imageFile;
  Future takePhoto(ImageSource source) async {
    try {
      final pickFile = await imagePicker.pickImage(source: source);
      final dir = await getTemporaryDirectory();

      final targetfile = '${dir.absolute.path}/temp.jpg';

      final image = await FlutterImageCompress.compressAndGetFile(
        pickFile!.path,
        targetfile,
        minHeight: 1000,
        minWidth: 1000,
      );
      setState(() {
        // ignore: empty_statements
        if (image == null) {}

        imageFile = File(image!.path);

        imageUpload(imageFile!, id);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Widget imageProfile() {
    return Container(
      height: 150,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Text(
                'Choose Profile Photo',
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  TextButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.camera);
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 30,
                      ),
                      label: const Text(
                        'Camera',
                      ))
                ],
              ),
              Column(
                children: [
                  TextButton.icon(
                      onPressed: () {
                        takePhoto(ImageSource.gallery);
                      },
                      icon: const Icon(
                        Icons.photo_camera_back_rounded,
                        size: 30,
                      ),
                      label: const Text('Gallery'))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget imageShow(image) {
    return Container(
      color: Color.fromARGB(255, 4, 34, 111),
      child: Center(
        child: CircleAvatar(
            maxRadius: 150, foregroundImage: CachedNetworkImageProvider(i)),
      ),
    );
  }

  Widget fixedImage() {
    return SizedBox(
      child: ClipRRect(
        child: Image.asset(
          'asset/img/female1.png',
        ),
      ),
    );
  }

  bool isButtonEnabled = true;

  TextEditingController t1 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(
                top: 30,
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Row(
                          children: [
                            SizedBox(
                              child: Image(
                                image: AssetImage(
                                  'asset/img/music.jpg',
                                ),
                                width: 50,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                'Mijazz',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20),
                    child: Row(
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'asset/img/aibackground.jpg',
                                  // opacity: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 20,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return i != '' ? imageShow(i) : fixedImage();
                                });
                          },
                          child: Row(
                            children: [
                              // ignore: unnecessary_null_comparison
                              i != ''
                                  ? CircleAvatar(
                                      radius: 60.0,
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                        i,
                                        errorListener: (p0) =>
                                            CircularProgressIndicator(),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 60.0,
                                      foregroundImage:
                                          AssetImage('asset/img/female1.png'),
                                    )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 110,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (builder) => imageProfile(),
                                );
                              },
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.red,
                                size: 30,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          left: 20,
                          top: 5,
                          child: Row(
                            children: [
                              Text(
                                '$name',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                      Positioned(
                          left: 20,
                          top: 30,
                          child: Row(
                            children: [
                              Text(
                                email,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            ],
                          )),
                      Positioned(
                          right: 30,
                          bottom: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(255, 5, 43, 74),
                            ),
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'U-id: ${id}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () {
                                      if (id.isEmpty) {
                                      } else {
                                        FlutterClipboard.controlC(
                                            id.toString());
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(children: [
                        Row(
                          children: [
                            Visibility(
                              visible: isButtonEnabled,
                              child: const Padding(
                                padding: EdgeInsets.only(top: 30, left: 0),
                                child: Text(
                                  'LIBRARY',
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Visibility(
                            visible: isButtonEnabled,
                            child: MaterialButton(
                              disabledColor: Colors.grey,
                              onPressed: isButtonEnabled
                                  ? () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.black,
                                            title: Text('Forgot Password?'),
                                            titleTextStyle:
                                                TextStyle(color: Colors.white),
                                            content: Text(
                                                'Do you want to change your  password?'),
                                            contentTextStyle:
                                                TextStyle(color: Colors.white),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('No',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black))),
                                              ElevatedButton(
                                                  style: const ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStatePropertyAll(
                                                              Colors.red)),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    audioplayer.stop();
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const ForgotPassword()));
                                                  },
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  : null,
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: MediaQuery.of(context).size.height - 650,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                                onPressed: () async {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.black,
                                        title: Text(
                                          'Log Out?',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        titleTextStyle:
                                            TextStyle(color: Colors.white),
                                        content: Text(
                                            'Are you sure want to Log Out?'),
                                        contentTextStyle:
                                            TextStyle(color: Colors.white),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Cancle',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                          ElevatedButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.red)),
                                              onPressed: () async {
                                                sp = await SharedPreferences
                                                    .getInstance();
                                                await GoogleSignIn().signOut();
                                                sp.clear();

                                                MusicPlayUiState
                                                        .isPlayerInitialized =
                                                    false;

                                                MusicPlayUiState.beforeid = 0;
                                                audioplayer.dispose();
                                                global.isPlayer = false;

                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Splash()),
                                                    (route) => false);
                                                Fluttertoast.showToast(
                                                    msg: 'Logout Successful');
                                              },
                                              child: Text(
                                                'Log Out',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                
                                
                                },
                                icon: Icon(
                                  Icons.exit_to_app_rounded,
                                  color: const Color.fromARGB(255, 254, 20, 3),
                                ),
                                label: Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 254, 20, 3)),
                                )),
                          ],
                        ),
                      ])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
