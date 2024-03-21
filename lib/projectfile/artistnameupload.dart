import 'dart:convert';
import 'dart:io';
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ArtisNameUpload extends StatefulWidget {
  const ArtisNameUpload({super.key});

  @override
  State<ArtisNameUpload> createState() => _ArtisNameUploadState();
}

class _ArtisNameUploadState extends State<ArtisNameUpload> {
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();

  Future uploadArtistDetails(File image) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse('${UrlPage.link}artist.php'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          image.readAsBytesSync(),
          filename: image.path.split("/").last,
        ),
      );

      request.fields['title'] = t1.text;

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

      if (jsondata['status'] == true) {
        AwesomeDialog(
          context: context,
          animType: AnimType.bottomSlide,
          dismissOnTouchOutside: true,
          dialogType: DialogType.success,
          title: 'warning',
          desc: 'Password must be same',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  File audiofile = File('');

  File? imageFile;
  final ImagePicker imagePicker = ImagePicker();
  Future takePhoto(ImageSource source) async {
    try {
      final pickFile = await imagePicker.pickImage(source: source);
      setState(() {
        if (pickFile == null) {}

        imageFile = File(pickFile!.path);
        t2.value = TextEditingValue(text: imageFile!.path.split('/').last);
      });
    } catch (e) {}
  }

  GlobalKey<FormState> gk = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          body: Form(
            key: gk,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Title'),
                TextFormField(
                  validator: (value) {
                    if (t1.text.isEmpty) {
                      return 'Required';
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: t1,
                  decoration: InputDecoration(
                      hintText: 'Artist name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.black, width: 10))),
                ),
                Text('Image'),
                TextFormField(
                  validator: (value) {
                    if (t2.text.isEmpty) {
                      return 'Required';
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: t2,
                  decoration: InputDecoration(
                      hintText: 'Image',
                      suffixIcon: IconButton(
                          onPressed: () {
                            takePhoto(ImageSource.gallery).whenComplete(() {
                              setState(() {
                                t2.value = TextEditingValue(
                                    text: imageFile!.path
                                        .split('/')
                                        .last
                                        .toString());
                              });
                            });
                          },
                          icon: Icon(Icons.image)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.black, width: 10))),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (gk.currentState!.validate()) {
                        uploadArtistDetails(imageFile!);
                      }
                    },
                    child: const Text('Submit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
