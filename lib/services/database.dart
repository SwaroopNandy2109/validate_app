import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      Firestore.instance.collection('Users');

  Future addUserData(String name, String photoUrl) async {
    return await userCollection.document(uid).setData(
      {
        'username': name,
        'photoUrl': photoUrl,
        'upVotedPosts': [],
        'downVotedPosts': [],
      },
      merge: false,
    );
  }
}
