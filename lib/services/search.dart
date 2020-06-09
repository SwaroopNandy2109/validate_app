import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class SearchPosts extends SearchDelegate<QuerySnapshot> {
  final firestore = Firestore.instance;
  List<DocumentSnapshot> posts = [];

  deletePost(documentId) async {
    await DatabaseService()
        .deletePost(documentId); //not shwoing anything in list
  }

  getPosts() async {
    posts = [];

    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Posts')
        .orderBy("timestamp", descending: true)
        .getDocuments();
    posts.addAll(querySnapshot.documents);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  //
  @override
  Widget buildSuggestions(BuildContext context) {
    getPosts();
    posts.forEach((element) {
      print(element.data);
    });
    List<DocumentSnapshot> suggestions = [];
    suggestions = query.isEmpty
        ? posts
        : posts.where((doc) {
            String title = doc.data["title"];
            return title.startsWith(query);
          }).toList();
    return suggestions.isEmpty
        ? Center(
            child: Text('No results found..'),
          )
        : ListView.separated(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestions[index].data["title"]),
                subtitle: Text(suggestions[index].data["description"]),
              );
            },
            separatorBuilder: (context, index) => Divider(),
          );
  }
}
