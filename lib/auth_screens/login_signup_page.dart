import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/loading_widget.dart';
import 'package:validatedapp/constants/textStyle.dart';
import 'package:validatedapp/services/auth.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _focus = FocusNode();

  String _email;
  String _password;
  String _firstName = '';
  String _lastName = '';
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;
  bool _obscureText = true;
  bool _isFocused = false;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = false;
    });

    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signInWithEmail(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth
              .regWithEmail(_email, _password, _firstName + " " + _lastName);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _isLoginForm) {
          setState(() {
            _isLoading = true;
          });
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
        _showErrorMessageAlert();
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    _isFocused = false;
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focus.hasFocus;
    });
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4e54c8), Color(0xFF8f94fb)],
                ),
              ),
              child: _showForm(),
            ),
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
          title: Text(
            "Verify your account",
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Link to verify account has been sent to your email",
            style: GoogleFonts.ubuntu(),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Dismiss",
                style: GoogleFonts.ubuntu(),
              ),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _toggleForm() {
    List<Widget> widgetList = [];
    widgetList.add(
      Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            _isLoginForm ? 'Sign In' : 'Register',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold,fontSize: 60,color: Colors.white),
          ),
        ),
      ),
    );
    if (_isLoginForm) {
      widgetList.add(SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
      ));
      widgetList.add(showEmailInput());
      widgetList.add(showPasswordInput());
      widgetList.add(showPrimaryButton());
      widgetList.add(SizedBox(
        height: 25,
      ));
      widgetList.add(googleButton());
      widgetList.add(SizedBox(
        height: 25,
      ));
      widgetList.add(showSecondaryButton());
      widgetList.add(SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
      ));
    } else {
      widgetList.add(SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
      ));
      widgetList.add(showFirstNameInput());
      widgetList.add(showLastNameInput());
      widgetList.add(showEmailInput());
      widgetList.add(showPasswordInput());
      widgetList.add(showPrimaryButton());
      widgetList.add(SizedBox(
        height: 25,
      ));
      widgetList.add(showSecondaryButton());
    }

    return widgetList;
  }

  Widget _showForm() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: _toggleForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget googleButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.0),
      child: RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        padding: EdgeInsets.all(15.0),
        color: Colors.white,
        onPressed: () async {
          setState(() {
            _errorMessage = "";
            _isLoading = false;
          });
          try {
            setState(() {
              _isLoading = true;
            });
            String userId = await widget.auth.googleSignIn();
            setState(() {
              _isLoading = false;
            });
            if (userId.length > 0 && userId != null && _isLoginForm) {
              widget.loginCallback();
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.message;
            });
            _showErrorMessageAlert();
          }
        },
        icon: Icon(
          FontAwesomeIcons.google,
          color: Theme.of(context).primaryColor,
          size: 25.0,
        ),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'sign in with google'.toUpperCase(),
            style: GoogleFonts.ubuntu(
              color: Theme.of(context).primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.w700
            ),
          ),
        ),
      ),
    );
  }

  Widget showFirstNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFocused = false;
          });
        },
        child: TextFormField(
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: textInputDecoration.copyWith(
              hintText: 'First Name',
              prefixIcon: Icon(
                Icons.person,
              )),
          validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
          onSaved: (value) => _firstName = value.trim(),
          onChanged: (value) => _firstName = value.trim(),
        ),
      ),
    );
  }

  Widget showLastNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFocused = false;
          });
        },
        child: TextFormField(
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: textInputDecoration.copyWith(
              hintText: 'Last Name', prefixIcon: Icon(Icons.person)),
          validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
          onSaved: (value) => _lastName = value.trim(),
          onChanged: (value) => _lastName = value.trim(),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFocused = false;
          });
        },
        child: TextFormField(
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: textInputDecoration.copyWith(
              hintText: 'Email', prefixIcon: Icon(Icons.alternate_email)),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value.trim(),
        ),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 18),
        focusNode: _focus,
        maxLines: 1,
        obscureText: _obscureText,
        autofocus: false,
        decoration: textInputDecoration.copyWith(
          hintText: 'Password',
          prefixIcon: Icon(Icons.lock),
          suffixIcon: _isFocused
              ? GestureDetector(
                  child: Icon(
                    _obscureText
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 18.5,
                  ),
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password can\'t be empty';
          } else if (value.trim().length < 6) {
            return 'Length of Password can\'t be less than 6 characters';
          } else {
            return null;
          }
        },
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return Center(
      child: GestureDetector(
        child: Text(
            _isLoginForm
                ? 'Create an Account'.toUpperCase()
                : 'Have an Account? Sign in'.toUpperCase(),
            style: GoogleFonts.ubuntu(
                fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.white)),
        onTap: toggleFormMode,
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 18),
          height: 50.0,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            color: Colors.white,
            child: Text(
              _isLoginForm ? 'Login' : 'Create Account',
              style: GoogleFonts.ubuntu(
                  fontSize: 20.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700),
            ),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  void _showErrorMessageAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('Error'),
            content: Text(_errorMessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Fix It',
                    style: GoogleFonts.ubuntu(),
                  ))
            ],
          );
        });
  }
}
