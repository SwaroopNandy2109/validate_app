import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:validatedapp/constants/shared.dart';
import 'package:validatedapp/home.dart';

class TextPostPage extends StatefulWidget {
  @override
  _TextPostPageState createState() => _TextPostPageState();
}

class _TextPostPageState extends State<TextPostPage> {
  final StorageReference storageRef = FirebaseStorage.instance.ref();
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
              context, MaterialPageRoute(builder: (context) => HomePage())),
        ),
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
                maxLines: 15,
                validator: (val) =>
                    description == null ? 'Please provide a description' : null,
                onChanged: (val) => description = val.trim(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  validateAndSubmit() async {
    if (_formKey.currentState.validate()) {
      await handleSubmit();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    await CloudFunctions.instance
        .getHttpsCallable(functionName: 'addPost')
        .call(<String, dynamic>{
      "title": title,
      "description": description,
      "category": _selectedCategory,
      "type": "Text",
      "mediaUrl": "",
      "link": "",
    });

    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }
}
