import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/constants/textStyle.dart';
import 'package:validatedapp/services/auth.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;

  SignUp({this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';
  String firstName = '';
  String lastName = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Register',
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text("Sign in"))
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      decoration:
                      textInputDecoration.copyWith(hintText: 'First Name'),
                      validator: (value) =>
                      value.isEmpty ? "Enter First Name" : null,
                      onChanged: (value) {
                        setState(() => firstName = value);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration:
                      textInputDecoration.copyWith(hintText: 'Last Name'),
                      validator: (value) =>
                      value.isEmpty ? "Enter Last Name" : null,
                      onChanged: (value) {
                        setState(() => lastName = value);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (value) =>
                          value.isEmpty ? "Enter an email" : null,
                      onChanged: (value) {
                        setState(() => email = value);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (value) => value.length < 6
                          ? "Enter a password with 6+ characters"
                          : null,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() => password = value);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)
                      ),
                      color: Colors.deepPurple,
                      child: Text(
                        "Sign up".toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            loading = true;
                          });
                          dynamic result =
                              await _auth.regWithEmail(email, password);
                          if (result == null) {
                            setState(() {
                              error = "Please provide valid email";
                              loading = false;
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
