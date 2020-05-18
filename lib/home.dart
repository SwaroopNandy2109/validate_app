import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/services/auth.dart';
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
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resend link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
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
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
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
            PostPage(),
            ProfilePage(
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            ),
          ],
        ),
        floatingActionButton: Container(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
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
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(
                                  Icons.link,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 35,
                                child: Icon(
                                  Icons.textsms,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 35,
                                child: Icon(
                                  Icons.video_call,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 35,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
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
                  iconSize: 30.0,
                  icon: Icon(Icons.person,
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
