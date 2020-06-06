import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:validatedapp/constants/post_container.dart';
import 'package:validatedapp/models/user.dart';
import 'package:validatedapp/services/database.dart';

class TrendingBarPage extends StatefulWidget {
  @override
  _TrendingBarPageState createState() => _TrendingBarPageState();
}

class _TrendingBarPageState extends State<TrendingBarPage> {
  Firestore firestore = Firestore.instance;
  String categoryChoice = 'All';

  List<DocumentSnapshot> posts;
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();
  GlobalKey<RefreshIndicatorState> refreshIndicatorState;

  @override
  void initState() {
    super.initState();
    posts = [];
    refreshIndicatorState = GlobalKey<RefreshIndicatorState>();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
  }

  refreshList() async {
    posts = [];
    hasMore = true;
    lastDocument = null;
    setState(() {
      isLoading = false;
    });
    if (categoryChoice == 'All') {
      await getProducts();
    } else {
      await getCategoryProducts();
    }
  }

  deletePost(documentId) async {
    await DatabaseService().deletePost(documentId);
    await refreshList();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    getProducts();
    return Scaffold(
      body: RefreshIndicator(
        strokeWidth: 3.0,
        key: refreshIndicatorState,
        onRefresh: () async {
          await refreshList();
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: FlatButton.icon(
                  icon: Icon(Icons.arrow_drop_down),
                  label: Text(
                    categoryChoice,
                    style: GoogleFonts.ubuntu(fontSize: 17),
                  ),
                  onPressed: () => showCategoryModal(context),
                ),
              ),
              Expanded(
                child: posts.length == 0
                    ? !isLoading
                        ? Center(
                            child: Text(
                              'No Posts Available',
                              style: GoogleFonts.ubuntu(fontSize: 30),
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          List upVotes = posts[index].data["upVotedBy"];
                          List downVotes = posts[index].data["downVotedBy"];
                          return PostCard(
                            doc: posts[index],
                            deletePost: () async {
                              await deletePost(posts[index].documentID);
                            },
                            upVotes: upVotes,
                            downVotes: downVotes,
                            uid: user.uid,
                            refresh: () => refreshList(),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getProducts() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('Posts')
          .orderBy("numOfVotes", descending: true)
          .orderBy("timestamp", descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('Posts')
          .orderBy("numOfVotes", descending: true)
          .orderBy("timestamp", descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .getDocuments();
      print(1);
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    posts.addAll(querySnapshot.documents);
    setState(() {
      isLoading = false;
    });
  }

  getCategoryProducts() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('Posts')
          .where("category", isEqualTo: categoryChoice)
          .orderBy("numOfVotes", descending: true)
          .orderBy("timestamp", descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('Posts')
          .where("category", isEqualTo: categoryChoice)
          .orderBy("numOfVotes", descending: true)
          .orderBy("timestamp", descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .getDocuments();
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.documents.isNotEmpty) {
      lastDocument = querySnapshot.documents.last;
      posts.addAll(querySnapshot.documents);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  showCategoryModal(parentContext) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: parentContext,
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              dropdownOption('All'),
              dropdownOption('Politics'),
              dropdownOption('Sports'),
              dropdownOption('Economy'),
              dropdownOption('Business'),
              dropdownOption('Entertainment'),
            ],
          ),
        );
      },
    );
  }

  Widget dropdownOption(String title) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.ubuntu(
            fontWeight: title == categoryChoice ? FontWeight.bold : null,
            fontSize: 16.5),
      ),
      trailing: title == categoryChoice
          ? Icon(
              Icons.done,
              color: Colors.green,
              size: 28.0,
            )
          : null,
      onTap: () async {
        setState(() {
          categoryChoice = title;
        });
        Navigator.of(context).pop();
        await refreshList();
      },
    );
  }
}
