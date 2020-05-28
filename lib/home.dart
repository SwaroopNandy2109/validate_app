import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:validatedapp/models/user.dart';
import 'package:validatedapp/services/auth.dart';
import 'package:validatedapp/tabs/AddPostPages/imagepost.dart';
import 'package:validatedapp/tabs/AddPostPages/linkpost.dart';
import 'package:validatedapp/tabs/AddPostPages/textpost.dart';
import 'package:validatedapp/tabs/post_page.dart';
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
    print(user.email);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
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
              child: PostPage(),
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

                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'POST!',
                            style: GoogleFonts.ubuntu(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LinkPostPage()));
                                },
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Icon(
                                    FontAwesomeIcons.paperclip,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TextPostPage()));
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 35,
                                  child: Icon(
                                    FontAwesomeIcons.penAlt,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 35,
                                  child: Icon(
                                    FontAwesomeIcons.video,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ImagePostPage()));
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 35,
                                  child: Icon(
                                    FontAwesomeIcons.image,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.cancel,
                              color: Theme.of(context).primaryColor,
                              size: 25,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
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
