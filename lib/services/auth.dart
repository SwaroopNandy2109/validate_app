import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:validatedapp/models/user.dart';
import 'package:validatedapp/services/database.dart';

abstract class BaseAuth {
  Future<String> signInWithEmail(String email, String password);

  Future<String> regWithEmail(String email, String password, String name);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<String> updateProfilePhoto(String photoUrl);

  Future<String> updateUsername(String name);

  Future<bool> isEmailVerified();

  Future<String> googleSignIn();
}

class AuthService implements BaseAuth {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  Future<String> googleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    await DatabaseService(uid: user.uid)
        .addUserData(user.displayName, user.photoUrl);
    _userFromFirebaseUser(user);
    return user.uid;
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<String> signInWithEmail(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _userFromFirebaseUser(user);
    print("Login: " + user.displayName);
    return user.uid;
  }

  Future<String> regWithEmail(
      String email, String password, String name) async {
    UserUpdateInfo _updateInfo = UserUpdateInfo();
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _updateInfo.displayName = name;
    user.updateProfile(_updateInfo);
    _userFromFirebaseUser(user);
    await DatabaseService(uid: user.uid).addUserData(name,
        'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png');
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    print("Inside getCurrentUser " + user.photoUrl);
    return user;
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _auth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isEmailVerified;
  }

  Stream<User> get currentUser {
    return _auth.currentUser().asStream().map(_userFromFirebaseUser);
  }

  Future<String> updateProfilePhoto(String photoUrl) async {
    UserUpdateInfo _updateInfo = UserUpdateInfo();
    _updateInfo.photoUrl = photoUrl;
    FirebaseUser user = await getCurrentUser();

    user.updateProfile(_updateInfo);

    _userFromFirebaseUser(user);
    print(user.uid);
    return user.uid;
  }

  Future<String> updateUsername(String name) async {
    UserUpdateInfo _updateInfo = UserUpdateInfo();
    _updateInfo.displayName = name;
    FirebaseUser user = await getCurrentUser();

    user.updateProfile(_updateInfo);

    _userFromFirebaseUser(user);
    return user.uid;
  }
}
