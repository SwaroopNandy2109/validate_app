import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/constants/textStyle.dart';
import 'package:validatedapp/services/auth.dart';

class LoginPage extends StatefulWidget {
  final Function toggleView;

  LoginPage({this.toggleView});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Sign in",
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text("Register"))
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
              child: Center(
                child: ListView(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration:
                            textInputDecoration.copyWith(hintText: 'Email'),
                            validator: (value) =>
                            value.isEmpty ? "Enter email" : null,
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
                                ? "Enter password"
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
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            color: Colors.deepPurple,
                            child: Text(
                              "Sign in".toUpperCase(),
                              style: GoogleFonts.ubuntu(color: Colors.white,),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                setState(() => loading = true);
                                print("valid");
                                dynamic result = await _authService.signInWithEmail(
                                    email, password);
                                if (result == null) {
                                  setState(() {
                                    error =
                                    "Could not sign in with those credentials";
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
                    Divider(
                      height: 10.0,
                      color: Colors.black,
                      thickness: 2.0,
                    ),
                    SizedBox(height: 30,),
                    FlatButton.icon(
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
                  ],
                ),
              ),
            ),
          );
  }
}
