import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/post_container.dart';

class HomeBarPage extends StatefulWidget {
  @override
  _HomeBarPageState createState() => _HomeBarPageState();
}

class _HomeBarPageState extends State<HomeBarPage> {
  Firestore firestore = Firestore.instance;
  String categoryChoice = 'All';

  List<DocumentSnapshot> posts = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  ? Center(
                child: Text('No Data...'),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(doc: posts[index]);
                },
              ),
            ),
            isLoading
                ? Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              padding: EdgeInsets.all(5),
              color: Colors.yellowAccent,
              child: Text(
                'Loading',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : Container()
          ],
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
          .orderBy("timestamp", descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('Posts')
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
      onTap: () {
        setState(() {
          categoryChoice = title;
        });
        Navigator.of(context).pop();
      },
    );
  }
}
