import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validatedapp/constants/shared.dart';

class ViewPost extends StatefulWidget {
  final DocumentSnapshot doc;
  final List upVotes;
  final List downVotes;
  final String uid;

  ViewPost({
    this.doc,
    this.upVotes,
    this.downVotes,
    this.uid,
  });

  @override
  _ViewPostState createState() =>
      _ViewPostState(upVotes: this.upVotes, downVotes: this.downVotes);
}

class _ViewPostState extends State<ViewPost> {
  Firestore firestore = Firestore.instance;
  List upVotes;
  List downVotes;
  List<DocumentSnapshot> comments;
  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';

  _ViewPostState({this.upVotes, this.downVotes});

  final commentController = TextEditingController();

//  ScrollController _scrollController = ScrollController();
  String comment;

  @override
  void initState() {
    comments = [];
    getComments();
    super.initState();
  }

  getComments() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Posts')
        .document(widget.doc.documentID)
        .collection('Comments') //gadheeeee
        .orderBy('timestamp', descending: true)
        .getDocuments();
    comments.addAll(querySnapshot.documents); //try printing idhar waitt
  }

  @override
  Widget build(BuildContext context) {
    getComments();
    var date = widget.doc["timestamp"].toDate();
    int upVotesCount = upVotes.length;
    int downVotesCount = downVotes.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Posts',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        // hold on
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: comments.length + 1,
              itemBuilder: (context, index) {
                print(comments.length);
                comments.forEach((doc) => print(doc.data));
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 20, top: 20),
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<DocumentSnapshot>(
                          stream: Firestore.instance
                              .collection('Users')
                              .document(widget.doc["author"])
                              .snapshots(),
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: CachedNetworkImageProvider(
                                      !snapshot.hasData
                                          ? dummyPhotoUrl
                                          : snapshot.data["photoUrl"]),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    AutoSizeText(
                                      !snapshot.hasData
                                          ? 'Loading...'
                                          : snapshot.data["username"],
                                      maxLines: 1,
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800),
                                      minFontSize: 10,
                                      maxFontSize: 20,
                                    ),
                                    Text(Jiffy(date).yMMMd)
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        Divider(
                          height: 30,
                          thickness: 0.8,
                          color: Colors.grey,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AutoSizeText(
                                widget.doc["title"],
                                style: GoogleFonts.ubuntu(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AutoSizeText(
                                widget.doc["description"],
                                minFontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                maxFontSize: double.infinity,
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ),
                        widget.doc["mediaURL"] != '' || widget.doc["link"] != ''
                            ? SizedBox(height: 20)
                            : Container(),
                        widget.doc["mediaURL"] != ''
                            ? AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: CachedNetworkImageProvider(
                                            widget.doc["mediaURL"]),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        widget.doc['link'] != ""
                            ? SizedBox(height: 15)
                            : Container(),
                        widget.doc['link'] != ""
                            ? Row(
                                children: <Widget>[
                                  Text(
                                    'Related links',
                                    style: GoogleFonts.ubuntu(fontSize: 20),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Linkify(
                                      text: widget.doc["link"],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                      maxLines: 2,
                                      onOpen: (url) async {
                                        try {
                                          await launch(widget.doc["link"]);
                                        } catch (e) {}
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.arrowCircleUp,
                                  size: 35,
                                  color: upVotes.contains(widget.uid) == true
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    upVotes.contains(widget.uid)
                                        ? upVotes.remove(widget.uid)
                                        : upVotes.add(widget.uid);
                                    if (downVotes.contains(widget.uid)) {
                                      downVotes.remove(widget.uid);
                                    }
                                  });
                                  await CloudFunctions.instance
                                      .getHttpsCallable(
                                          functionName: 'upVotePost')
                                      .call(<String, dynamic>{
                                    'id': widget.doc.documentID
                                  });
                                }),
                            Text(NumberFormat.compact().format(upVotesCount),
                                style: GoogleFonts.ubuntu(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                            SizedBox(width: 10),
                            IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.arrowCircleDown,
                                  size: 35,
                                  color: downVotes.contains(widget.uid)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    downVotes.contains(widget.uid)
                                        ? downVotes.remove(widget.uid)
                                        : downVotes.add(widget.uid);
                                    if (upVotes.contains(widget.uid)) {
                                      upVotes.remove(widget.uid);
                                    }
                                  });
                                  await CloudFunctions.instance
                                      .getHttpsCallable(
                                          functionName: 'downVotePost')
                                      .call(<String, dynamic>{
                                    'id': widget.doc.documentID
                                  });
                                }),
                            Text(NumberFormat.compact().format(downVotesCount),
                                style: GoogleFonts.ubuntu(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  );
                } else
                  return comments.length == 0
                      ? Expanded(child: Text('No comments'))
                      : Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: Firestore.instance
                                .collection('Users')
                                .document(comments[index]["commentAuthor"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      snapshot.hasData
                                          ? dummyPhotoUrl
                                          : '${snapshot.data["photoUrl"]}'),
                                ),
                                title: Text(snapshot.hasData
                                    ? 'Loading...'
                                    : '${snapshot.data["username"]}'),
                                subtitle: Text(comments[index]["comment"]),
                                trailing: Row(
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.mode_edit)),
                                    IconButton(
                                        icon: Icon(
                                            FontAwesomeIcons.arrowAltCircleUp),
                                        onPressed: () {
                                          //upvote functionality
                                        }),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
              }, // itemBuilder
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: TextField(
                controller: commentController,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Comment here',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      await CloudFunctions.instance
                          .getHttpsCallable(functionName: 'addComment')
                          .call(<String, dynamic>{
                        'id': widget.doc.documentID,
                        'comment': commentController.text,
                      });
                      setState(() {
                        comment = commentController.text;
                      });
                      commentController.clear();
                    },
                  ),
                  hintStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
