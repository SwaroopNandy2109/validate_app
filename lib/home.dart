import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:validatedapp/models/user.dart';
import 'package:validatedapp/services/auth.dart';
import 'package:validatedapp/tabs/AddPostPages/addPostPage.dart';
import 'package:validatedapp/tabs/home_trending_page.dart';
import 'package:validatedapp/tabs/profile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTabOneSelected = true;
  bool isTabTwoSelected = false;
  PageController controller;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    _checkEmailVerification();
    getUser();
  }

  void getUser() async {
    FirebaseUser user = await AuthService().getCurrentUser();
  }

  void _checkEmailVerification() async {
    try {
      _isEmailVerified = await widget.auth.isEmailVerified();
      if (!_isEmailVerified) {
        _showVerifyEmailDialog();
      }
    } catch (e) {}
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: new Text(
            "Verify your account",
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          content: new Text(
            "Please verify account in the link sent to email",
            style: GoogleFonts.ubuntu(),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "Resend link",
                style: GoogleFonts.ubuntu(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text(
                "Dismiss",
                style: GoogleFonts.ubuntu(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: new Text(
            "Verify your account",
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          content: new Text(
            "Link to verify account has been sent to your email",
            style: GoogleFonts.ubuntu(),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "Dismiss",
                style: GoogleFonts.ubuntu(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: <Widget>[
            StreamProvider<User>.value(
              child: HomeTrendingPage(),
              value: AuthService().currentUser,
            ),
            StreamProvider<User>.value(
              value: AuthService().currentUser,
              child: ProfilePage(
                auth: widget.auth,
                logoutCallback: widget.logoutCallback,
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                _checkEmailVerification();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => CommonPostPage()));
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
              // elevation: 5.0,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  iconSize: 30.0,
                  icon: Icon(Icons.whatshot,
                      color: isTabOneSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey),
                  onPressed: () {
                    setState(() {
                      isTabOneSelected = true;
                      isTabTwoSelected = false;
                      controller.animateToPage(
                        0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                ),
                IconButton(
                  iconSize: 25.0,
                  icon: Icon(FontAwesomeIcons.userAlt,
                      color: isTabTwoSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey),
                  onPressed: () {
                    setState(() {
                      isTabTwoSelected = true;
                      isTabOneSelected = false;
                      controller.animateToPage(
                        1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
