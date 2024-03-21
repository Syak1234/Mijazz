import 'dart:convert';

import 'dart:io';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicUpload extends StatefulWidget {
  const MusicUpload({Key? key}) : super(key: key);

  @override
  _MusicUploadState createState() => _MusicUploadState();
}

class _MusicUploadState extends State<MusicUpload> {
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  TextEditingController t4 = TextEditingController();
  TextEditingController t5 = TextEditingController();
  TextEditingController t6 = TextEditingController();
  TextEditingController t7 = TextEditingController();
  TextEditingController t8 = TextEditingController();
  TextEditingController t9 = TextEditingController();
  TextEditingController t10 = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  Future uploadMusicDetails(File fileaudio, File image) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    try {
      print(fileaudio.toString());

      var request = http.MultipartRequest(
          "POST", Uri.parse('${UrlPage.link}musicupload.php'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          image.readAsBytesSync(),
          filename: image.path.split("/").last,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileaudio.readAsBytesSync(),
          filename: fileaudio.path.split("/").last,
        ),
      );

      request.fields['title'] = t1.text;
      request.fields['artist'] = t2.text;
      request.fields['album'] = t3.text;
      request.fields['genre'] = t4.text;
      request.fields['duration'] = t5.text;
      request.fields['release_date'] = t6.text;
      request.fields['file_format'] = t7.text;
      request.fields['Lyrics'] = t9.text;

      var response = await request.send();

      var responded = await http.Response.fromStream(response);

      var jsondata = jsonDecode(responded.body);
      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(jsondata.toString()),
            );
          });
      // final res = await http.post(Uri.parse('${UrlPage.link}musicupload.php'),
      //     body: data);
      // final jsondata = jsonDecode(res.body);
      // const jsondata = true;
      if (jsondata['status'] == true) {
        AwesomeDialog(
          context: context,
          animType: AnimType.bottomSlide,
          dismissOnTouchOutside: true,
          dialogType: DialogType.success,
          // btnOkColor: Colors.green,
          title: 'warning',
          desc: 'Password must be same',
          btnOkOnPress: () {
            // Navigator.pop(context);
          },
        ).show();
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: e.toString());
      print(e);
      Navigator.pop(context);
    }
    // Navigator.pop(context);
  }

  File audiofile = File('');

  File? imageFile;
  final ImagePicker imagePicker = ImagePicker();
  Future takePhoto(ImageSource source) async {
    try {
      final pickFile = await imagePicker.pickImage(source: source);
      setState(() {
        // ignore: empty_statements
        if (pickFile == null) {}

        imageFile = File(pickFile!.path);
        t8.value = TextEditingValue(text: imageFile!.path.split('/').last);
        // imageUpload(imageFile!, id);
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload your music with all requirement details:'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Form(
                key: key,
                // autovalidateMode: AutovalidateMode.always,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('Title'.toUpperCase())),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t1.text.isEmpty) {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t1,
                        decoration: InputDecoration(
                            hintText: 'Title',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('artist'.toUpperCase())),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t2.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t2,
                        decoration: InputDecoration(
                            hintText: 'artist',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('album'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t3,
                        decoration: InputDecoration(
                            hintText: 'album',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('genre'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t4.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t4,
                        decoration: InputDecoration(
                            hintText: 'genre',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('duration'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t5.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t5,
                        decoration: InputDecoration(
                            hintText: 'duration',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('release_date'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t6.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t6,
                        decoration: InputDecoration(
                            hintText: 'release_date',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('file_format'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (t7.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t7,
                        decoration: InputDecoration(
                            hintText: 'file_format',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('image'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        validator: (value) {
                          if (value == '') {
                            return 'Required';
                          }
                        },
                        controller: t8,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  takePhoto(ImageSource.gallery);
                                },
                                icon: Icon(Icons.image)),
                            hintText: 'image',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('Lyrics'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        maxLines: null,
                        minLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (t9.text == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t9,
                        decoration: InputDecoration(
                            hintText: 'Lyrics',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        alignment: Alignment.bottomLeft,
                        child: Text('music file'.toUpperCase())),
                    Container(
                      width: 320,
                      child: TextFormField(
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value == '') {
                            return 'Required';
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: t10,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowMultiple: false,
                                          allowedExtensions: [
                                        'mp3',
                                        'wav',
                                        'flac',
                                      ]);

                                  if (result != null) {
                                    File file = File(
                                        result.files.first.path.toString());
                                    audiofile = file;

                                    print(file.path);
                                    t10.value =
                                        TextEditingValue(text: file.path);
                                    // t10.text = file.path.toString();
                                    // t10.value =File(path)
                                  } else {
                                    // User canceled the picker
                                  }
                                  // await
                                  // final result =
                                  // final x = result.path;
                                  // print(x);
                                },
                                icon: Icon(Icons.file_upload)),
                            hintText: 'Music file',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.black, width: 10))),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: MaterialButton(
                          colorBrightness: Brightness.light,
                          splashColor: Colors.blue,
                          color: Colors.red,
                          onPressed: () {
                            if (key.currentState!.validate()) {
                              uploadMusicDetails(audiofile, imageFile!);
                              // showDialog(
                              //     context: context,
                              //     builder: (context) {
                              //       return AlertDialog(
                              //         content: Text(x.toString()),
                              //         actions: [
                              //           ElevatedButton(
                              //               onPressed: () =>
                              //                   Navigator.of(context).pop(),
                              //               child: Text('Ok'))
                              //         ],
                              //       );
                              //     });
                            }
                          },
                          child: Text('Submit')),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
