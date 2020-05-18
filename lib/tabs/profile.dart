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
    return loading ? Loading():Scaffold(
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
                child: Icon(
                  Icons.account_circle,
                  size: 50,
                  color: Colors.white,
                ),
                backgroundColor: Colors.grey[400],
                radius: 50,
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
                  "Carry Minati",
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
                  "carryminati@tiktokkeliyeban.com",
                  style: styleText,
                ),
              ],
            ),
            Divider(
              height: 30.0,
              color: Colors.white,
            ),
            Row(
              children: <Widget>[
                Icon(Icons.cake),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "who TF cares!",
                  style: styleText,
                ),
              ],
            ),
            SizedBox(
              height: 50,
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
