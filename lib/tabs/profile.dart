import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image/image.dart' as Im;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/constants/textStyle.dart';
import 'package:validatedapp/models/user.dart';
import 'package:validatedapp/services/auth.dart';
import 'package:validatedapp/services/database.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.logoutCallback});

  final VoidCallback logoutCallback;
  final BaseAuth auth;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final StorageReference storageRef = FirebaseStorage.instance.ref();

  bool loading = false;
  File file;
  String postId = Uuid().v4();
  String name;

  @override
  void initState() {
    super.initState();
    file = null;
  }

  getPhoto(ImageSource source) async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: source);
    print("Just before cropper");
    if (image != null) {
      print("Inside cropper");
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepPurple,
          toolbarTitle: "Crop Profile Photo",
          statusBarColor: Colors.deepPurple[600],
          backgroundColor: Colors.white,
        ),
      );

      setState(() {
        this.file = cropped;
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Change Profile Picture"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: () async {
                  await getPhoto(ImageSource.camera);
                  setState(() {
                    loading = true;
                  });
                  await handleImageSubmit();
                  setState(() {
                    loading = false;
                  });
                }),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: () async {
                  await getPhoto(ImageSource.gallery);
                  setState(() {
                    loading = true;
                  });
                  await handleImageSubmit();
                  setState(() {
                    loading = false;
                  });
                }),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  handleImageSubmit() async {
    setState(() {
      loading = true;
    });
    print("before compress");
    await compressImage();
    print("after compress");
    String mediaUrl = await uploadImage(file);

    String uid = await widget.auth.updateProfilePhoto(mediaUrl);

    DatabaseService(uid: uid).updateProfilePhoto(mediaUrl);

    setState(() {
      file = null;
      postId = Uuid().v4();
      loading = false;
    });
  }

  changeUsername(parentContext, name) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text("Change Username"),
            content: TextFormField(
              style:
                  GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: textInputDecoration.copyWith(
                  labelText: '$name', prefixIcon: Icon(Icons.person)),
              validator: (value) =>
                  value.isEmpty ? 'Name can\'t be empty' : null,
              onSaved: (value) => name = value.trim(),
              onChanged: (value) => name = value.trim(),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Update"),
                onPressed: () => {
                  handleNameSubmit(),
                  Navigator.pop(context),
                },
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Cancel"),
                onPressed: () => {Navigator.pop(context)},
              )
            ],
          );
        });
  }

  handleNameSubmit() async {
    setState(() {
      loading = true;
    });
    String uid = await widget.auth.updateUsername(name);
    DatabaseService(uid: uid).updateUsername(name);

    setState(() {
      loading = false;
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Loading();
    } else {
      return loading
          ? Loading()
          : StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('Users')
                  .document(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  DocumentSnapshot userSnapshot = snapshot.data;
                  print(userSnapshot['photoUrl']);
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        'Profile',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                    ),
                    body: Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: GestureDetector(
                              onTap: () => {selectImage(context)},
                              child: Stack(children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: userSnapshot['photoUrl'] ==
                                            null
                                        ? CachedNetworkImageProvider(
                                            'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png')
                                        : CachedNetworkImageProvider(
                                            userSnapshot['photoUrl']),
                                    backgroundColor: Colors.grey[400],
                                    radius: 70,
                                  ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    child: CircleAvatar(
                                      radius: 15,
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          Divider(
                            height: 60.0,
                            color: Colors.white,
                          ),
                          GestureDetector(
                            onTap: () => {
                              changeUsername(context, userSnapshot['username'])
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.person),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "${userSnapshot['username']}",
                                  style: styleText,
                                ),
                                Spacer(flex: 1,),
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                          Divider(
                            height: 30.0,
                            color: Colors.white,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.email),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "${user.email}",
                                style: styleText,
                              ),
                            ],
                          ),
                          Divider(
                            height: 30.0,
                            color: Colors.white,
                          ),
                          FlatButton.icon(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await signOut();
                            },
                            icon: Icon(Icons.exit_to_app),
                            label: Text(
                              'Logout'.toUpperCase(),
                              style: GoogleFonts.ubuntu(),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else
                  return Loading();
              });
    }
  }
}
