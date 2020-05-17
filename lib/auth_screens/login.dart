import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/services/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Center(
              child: FlatButton.icon(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                padding: EdgeInsets.all(15.0),
                color: Colors.deepPurple,
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  await _authService.googleSignIn();
                },
                icon: Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                  size: 25.0,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'sign in with google'.toUpperCase(),
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
