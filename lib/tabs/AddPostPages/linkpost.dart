import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:validatedapp/constants/shared.dart';
import 'package:validatedapp/services/fetch_preview.dart';

class LinkPostPage extends StatefulWidget {
  @override
  _LinkPostPageState createState() => _LinkPostPageState();
}

class _LinkPostPageState extends State<LinkPostPage> {
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory;
  String title;
  String description;
  String link;
  var data;

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

  void loadPreview() {
    link = FetchPreview().validateUrl(link);
    FetchPreview().getPreview(link).then((res) {
      setState(() {
        data = res;
      });
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
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
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  hintText: 'http://',
                  hintStyle: GoogleFonts.ubuntu(),
                  fillColor: Colors.purple[45],
                  filled: true,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      loadPreview();
                    },
                    child: Icon(
                      FontAwesomeIcons.eye,
                    ),
                  ),
                ),
                maxLines: 3,
                validator: (val) =>
                    link == null ? 'Please provide a link' : null,
                onChanged: (val) {
                  link = val.trim();
                },
              ),
              SizedBox(
                height: 10,
              ),
              _buildPreviewWidget(),
            ],
          ),
        ),
      ),
    );
  }

  validateAndSubmit() async {
    if (_formKey.currentState.validate()) {
      await handleSubmit();
      Navigator.pop(context);
    }
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    CloudFunctions.instance
        .getHttpsCallable(functionName: 'addPost')
        .call(<String, dynamic>{
      "title": title,
      "description": description,
      "category": _selectedCategory,
      "type": "link",
      "mediaUrl": "",
      "link": link,
    });
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  _buildPreviewWidget() {
    if (data == null) {
      return Container();
    } else {
      if (data['error'] != null) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.purple[100],
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text("Invalid URL"),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.purple[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Image.network(
                  data['image'],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          data['description'],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 4,
                            ),
                            Container(
                              child: Text(link,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}
