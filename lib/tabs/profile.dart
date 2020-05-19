import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/constants/textStyle.dart';
import 'package:validatedapp/services/auth.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.logoutCallback});

  final VoidCallback logoutCallback;
  final BaseAuth auth;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : StreamBuilder<FirebaseUser>(
            stream: AuthService().currentUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                FirebaseUser user = snapshot.data;
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
                          child: CircleAvatar(
                            backgroundImage: user.photoUrl == null
                                ? CachedNetworkImageProvider(
                                    'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png')
                                : CachedNetworkImageProvider(user.photoUrl),
                            backgroundColor: Colors.grey[400],
                            radius: 70,
                          ),
                        ),
                        Divider(
                          height: 60.0,
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.person),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "${user.displayName}",
                              style: styleText,
                            ),
                          ],
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

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}
