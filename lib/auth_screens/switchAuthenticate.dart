import 'package:flutter/material.dart';
import 'package:validatedapp/auth_screens/login.dart';
import 'package:validatedapp/auth_screens/signup.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  bool showSignIn = true;

  @override
  Widget build(BuildContext context) {
    if(showSignIn == true)
    {
      return LoginPage(toggleView: toggleView);
    }
    else
    {
      return SignUp(toggleView: toggleView);
    }
  }
}
