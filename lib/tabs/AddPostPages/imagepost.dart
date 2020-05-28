import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:validatedapp/constants/shared.dart';

import '../../home.dart';

class ImagePostPage extends StatefulWidget {
  @override
  _ImagePostPageState createState() => _ImagePostPageState();
}

class _ImagePostPageState extends State<ImagePostPage> {
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  File file;
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory;
  String title;
  String description;
  bool isUploading = false;
  String postId = Uuid().v4();
  List<String> categories = [
    'Politics',
    'Sports',
    'Economy',
    'Business',
    'Entertainment'
  ];

  @override
  Widget build(BuildContext context) {
    return buildUploadForm();
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()))),
        title: Text(
          'Add Post',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: isUploading ? null : () => validateAndSubmit(),
              child: Text(
                'Post',
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    color: isUploading ? Colors.white30 : Colors.white,
                    fontSize: 20),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              isUploading ? LinearProgressIndicator() : Text(""),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                decoration: textInputDecoration,
                value: _selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      '$cat',
                      style: GoogleFonts.ubuntu(),
                    ),
                  );
                }).toList(),
                hint: Text(
                  'Choose a category',
                  style: GoogleFonts.ubuntu(),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (val) => _selectedCategory == null
                    ? 'Please choose a category'
                    : null,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                    hintText: 'Give A Interesting Title...',
                    hintStyle: GoogleFonts.ubuntu(),
                    fillColor: Colors.purple[45],
                    filled: true),
                validator: (val) =>
                    title == null ? 'Please provide a title' : null,
                onChanged: (val) => title = val.trim(),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  hintText: 'Give A Description for your post...',
                  hintStyle: GoogleFonts.ubuntu(),
                  fillColor: Colors.purple[45],
                  filled: true,
                ),
                maxLines: 10,
                validator: (val) =>
                    description == null ? 'Please provide a description' : null,
                onChanged: (val) => description = val.trim(),
              ),
              SizedBox(height: file == null ? 70 : 20),
              file != null
                  ? FlatButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: () {
                        setState(() {
                          file = null;
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Clear Image',
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1.0),
                      ),
                      color: Colors.red[400],
                    )
                  : Text(""),
              (file != null)
                  ? SizedBox(
                      height: 20,
                    )
                  : Text(""),
              file == null
                  ? Column(
                      children: <Widget>[
                        Text(
                          'Select an Image from'.toUpperCase(),
                          style: GoogleFonts.ubuntu(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                await getPhoto(ImageSource.camera);
                              },
                              child: CircleAvatar(
                                child: Icon(FontAwesomeIcons.camera, size: 40),
                                radius: 50,
                              ),
                            ),
                            Text(
                              'OR',
                              style: GoogleFonts.ubuntu(
                                  fontSize: 35, color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await getPhoto(ImageSource.gallery);
                              },
                              child: CircleAvatar(
                                child: Icon(FontAwesomeIcons.image, size: 40),
                                radius: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      height: 220.0,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(file),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  validateAndSubmit() async {
    if (_formKey.currentState.validate() && file != null) {
      await handleSubmit();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  getPhoto(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        compressQuality: 75,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepPurple,
          toolbarTitle: "Crop Photo",
          statusBarColor: Colors.deepPurple[600],
          backgroundColor: Colors.white,
        ),
      );

      setState(() {
        this.file = cropped;
      });
    }
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    downloadUrl.replaceAll('.jpg', '_400x400.jpg');
    print(downloadUrl);
    return downloadUrl;
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    String mediaUrl = await uploadImage(file);
    await CloudFunctions.instance
        .getHttpsCallable(functionName: 'addPost')
        .call(<String, dynamic>{
      "title": title,
      "description": description,
      "category": _selectedCategory,
      "type": "Image",
      "mediaUrl": mediaUrl,
      "link": "",
    });
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }
}
