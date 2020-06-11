import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  File file;
  String postId = Uuid().v4();
  String name = '';

  @override
  void initState() {
    super.initState();
    file = null;
  }

  getPhoto(ImageSource source) async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 75,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepPurple,
          toolbarTitle: "Crop Profile Photo",
          toolbarWidgetColor: Colors.white,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            "Change Profile Picture",
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            SimpleDialogOption(
                child: Text(
                  "Photo with Camera",
                  style: GoogleFonts.ubuntu(),
                ),
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
                child: Text(
                  "Image from Gallery",
                  style: GoogleFonts.ubuntu(),
                ),
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
              child: Text(
                "Cancel",
                style: GoogleFonts.ubuntu(),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageRef
        .child("profilepics/profile_pic$postId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    downloadUrl = downloadUrl.replaceAll('.jpg', '_640x640.jpg');
    return downloadUrl;
  }

  handleImageSubmit() async {
    setState(() {
      loading = true;
    });

    String mediaUrl = await uploadImage(file);

    String uid = await AuthService().updateProfilePhoto(mediaUrl);
    DocumentSnapshot prevImageSnap =
        await Firestore.instance.collection('Users').document(uid).get();
    String prevImageUrl = prevImageSnap.data["photoUrl"];
    StorageReference prevImageDeleteRef =
        await FirebaseStorage.instance.getReferenceFromUrl(prevImageUrl);
    await prevImageDeleteRef.delete();
    await DatabaseService(uid: uid).updateProfilePhoto(mediaUrl);
    StorageReference deleteRef = await FirebaseStorage.instance
        .getReferenceFromUrl(mediaUrl.replaceAll('_640x640.jpg', '.jpg'));
    await deleteRef.delete();
    setState(() {
      file = null;
      postId = Uuid().v4();
      loading = false;
    });
  }

  changeUsername(parentContext, username) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              "Change Username",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                initialValue: username,
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: textInputDecoration.copyWith(
                    labelText: 'Username', prefixIcon: Icon(Icons.person)),
                validator: (value) =>
                    value.isEmpty ? 'Name can\'t be empty' : null,
                onSaved: (value) => name = value.trim(),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text(
                  "Update",
                  style: GoogleFonts.ubuntu(),
                ),
                onPressed: () => {
                  if (validateAndSave() == true)
                    {handleNameSubmit(username), Navigator.pop(context)}
                },
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text(
                  "Cancel",
                  style: GoogleFonts.ubuntu(),
                ),
                onPressed: () => {Navigator.pop(context)},
              )
            ],
          );
        });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  handleNameSubmit(username) async {
    if (validateAndSave()) {
      setState(() {
        loading = true;
      });
      String uid = await AuthService()
          .updateUsername(name.isEmpty || name == "" ? username : name);
      await DatabaseService(uid: uid)
          .updateUsername(name.isEmpty || name == "" ? username : name);
      setState(() {
        loading = false;
      });
    }
  }

  showLogoutConfDialog(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              'Confirm Logout',
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to Logout?',
              style: GoogleFonts.ubuntu(),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      loading = true;
                    });
                    await signOut();
                  },
                  child: Text('Yes', style: GoogleFonts.ubuntu())),
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.ubuntu())),
            ],
          );
        });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {}
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
                  var userSnapshot = snapshot.data;
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
                              onTap: () => selectImage(context),
                              child: Stack(children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: userSnapshot
                                              .data['photoUrl'] ==
                                          null
                                      ? CachedNetworkImageProvider(
                                          'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png')
                                      : CachedNetworkImageProvider(
                                          userSnapshot.data['photoUrl']),
                                  backgroundColor: Colors.grey[400],
                                  radius: 70,
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    padding: EdgeInsets.all(2.0),
                                    child: CircleAvatar(
                                      radius: 10,
                                      child: Icon(
                                        Icons.edit,
                                        size: 12,
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
                              changeUsername(
                                  context, userSnapshot.data['username'])
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.person),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "${userSnapshot.data['username']}",
                                  style: styleText,
                                ),
                                Spacer(
                                  flex: 1,
                                ),
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
                            onPressed: () => showLogoutConfDialog(context),
                            icon: Icon(
                              Icons.exit_to_app,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Logout'.toUpperCase(),
                              style: GoogleFonts.ubuntu(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
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
