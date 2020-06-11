import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DatabaseService {
  String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      Firestore.instance.collection('Users');

  final CollectionReference postCollection =
      Firestore.instance.collection('Posts');

  addUserData(String name, String photoUrl) async {
    await userCollection.document(uid).setData(
      {
        'username': name,
        'photoUrl': photoUrl,
        'upVotedPosts': [],
        'downVotedPosts': [],
      },
    );
  }

  updateProfilePhoto(String photoUrl) async {
    await userCollection.document(uid).updateData({'photoUrl': photoUrl});
  }

  updateUsername(String name) async {
    await userCollection.document(uid).updateData({'username': name});
  }

  deletePost(String documentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: 'deletePost')
        .call(<String, dynamic>{
      "id": documentId,
    });
  }
}
