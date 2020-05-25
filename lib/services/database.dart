import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    );
  }

  Future updateProfilePhoto(String photoUrl) async {
    userCollection.document(uid).updateData({'photoUrl': photoUrl});
  }

  Future updateUsername(String name) async {
    userCollection.document(uid).updateData({'username': name});
  }

  addPost() async {
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addPost',
      );
      await callable.call(<String, dynamic>{
        "title": "New Post from app",
        "description": "Adding a new post from app 2",
        "category": "Sports",
        "type": "Link",
        "mediaUrl": "Not Present",
        "link": "https://www.google.com"
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
