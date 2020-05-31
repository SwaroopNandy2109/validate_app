import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DatabaseService {
  String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      Firestore.instance.collection('Users');

  final CollectionReference postCollection =
      Firestore.instance.collection('Posts');

  Future addUserData(String name, String photoUrl) async {
    return await userCollection.document(uid).setData(
      {
        'username': name,
        'photoUrl': photoUrl,
        'upVotedPosts': [],
        'downVotedPosts': [],
      },
    );
  }

  Future updateProfilePhoto(String photoUrl) async {
    userCollection.document(uid).updateData({'photoUrl': photoUrl});
  }

  Future updateUsername(String name) async {
    userCollection.document(uid).updateData({'username': name});
  }

  Future deletePost(String documentId) async {
    return await CloudFunctions.instance
        .getHttpsCallable(functionName: 'deletePost')
        .call(<String, dynamic>{
      "id": documentId,
    });
  }
}
