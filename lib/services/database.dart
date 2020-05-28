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
    );
  }

  Future updateProfilePhoto(String photoUrl) async {
    userCollection.document(uid).updateData({'photoUrl': photoUrl});
  }

  Future updateUsername(String name) async {
    userCollection.document(uid).updateData({'username': name});
  }

  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await Firestore.instance
        .collection("Posts")
        .orderBy("timestamp", descending: true)
        .limit(10)
        .getDocuments())
        .documents;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await Firestore.instance
        .collection("movies")
        .orderBy("rank")
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(10)
        .getDocuments())
        .documents;
  }
}
