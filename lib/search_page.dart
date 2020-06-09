import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/services/auth.dart';
import 'package:validatedapp/tabs/view_post.dart';
import 'package:validatedapp/models/user.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> posts = [];
  List<DocumentSnapshot> suggestions = [];
  bool isLoading = false;
  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  getPosts() async {
    posts = [];
    suggestions = [];
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await Firestore.instance.collection('Posts').getDocuments();
    setState(() {
      isLoading = false;
    });
    posts.addAll(snapshot.documents);
    suggestions = posts;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: AuthService().currentUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String uid = snapshot.data.uid;
            return Scaffold(
              body: SafeArea(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      buildSearchField(context),
                      buildResultsListView(uid)
                    ],
                  ),
                ),
              ),
            );
          } else
            return Center(child: CircularProgressIndicator());
        });
  }

  buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 10),
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by title...',
          hintStyle: GoogleFonts.ubuntu(fontSize: 18),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(),
          prefixIcon: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => searchController.clear()),
        ),
        onChanged: (val) {
          setState(() {
            suggestions = val.isEmpty
                ? posts
                : posts.where((doc) {
                    String title = doc.data["title"];
                    return title.contains(val) ||
                        title.contains(val.toUpperCase()) ||
                        title.contains(val.toLowerCase()) ||
                        title.startsWith(val.toUpperCase()) ||
                        title.startsWith(val.toLowerCase());
                  }).toList();
          });
        },
      ),
    );
  }

  buildResultsListView(String uid) {
    return Expanded(
      child: suggestions.isEmpty
          ? Center(
              child: !isLoading
                  ? Text('No Results Found..')
                  : CircularProgressIndicator())
          : ListView.separated(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Card(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance
                          .collection('Users')
                          .document(suggestions[index].data["author"])
                          .snapshots(),
                      builder: (context, snapshot) {
                        return ListTile(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPost(
                                          doc: suggestions[index],
                                          downVotes: suggestions[index]
                                              .data["downVotedBy"],
                                          upVotes: suggestions[index]
                                              .data["upVotedBy"],
                                          uid: uid,
                                        )));
                            getPosts();
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: CachedNetworkImageProvider(
                                !snapshot.hasData
                                    ? dummyPhotoUrl
                                    : snapshot.data["photoUrl"]),
                          ),
                          title: Text(
                            !snapshot.hasData
                                ? 'Loading...'
                                : snapshot.data["username"],
                            maxLines: 1,
                            style: GoogleFonts.ubuntu(),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.symmetric(vertical: 7.0),
                            child: Text(suggestions[index].data["title"]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 8),
            ),
    );
  }
}
