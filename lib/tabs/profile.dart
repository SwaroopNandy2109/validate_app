import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:validatedapp/constants/textstyle.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                  "Name idhar aayega",
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
                  "Email idhar aayega",
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
                  "Date idhar jaayega",
                  style: styleText,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
