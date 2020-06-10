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
  List<DocumentSnapshot> comments = [];
  List<List> commentUpVotes = [];
  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';
  bool isLoadingComments = false;

  _ViewPostState({this.upVotes, this.downVotes});

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getComments();
  }

  getComments() async {
    comments = [];
    commentUpVotes = [];
    QuerySnapshot querySnapshot;
    setState(() {
      isLoadingComments = true;
    });
    querySnapshot = await firestore
        .collection('Posts')
        .document(widget.doc.documentID)
        .collection('Comments')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      comments.addAll(querySnapshot.documents);
      comments.forEach((commentDoc) {
        commentUpVotes.add(commentDoc.data['upVotedBy']);
      });
      isLoadingComments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var date = widget.doc["timestamp"].toDate();
    int upVotesCount = upVotes.length;
    int downVotesCount = downVotes.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildPostContainer(date, upVotesCount, downVotesCount),
            _buildCommentsList(),
            ListTile(),
          ],
        ),
      ),
      bottomSheet: _buildCommentField(),
    );
  }

  _buildPostContainer(DateTime date, int upVotesCount, int downVotesCount) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
                            fontSize: 20, fontWeight: FontWeight.w800),
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
          SizedBox(
            height: 10,
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
              ? CachedNetworkImage(
                  imageUrl: widget.doc["mediaURL"],
                  fit: BoxFit.contain,
                  errorWidget: (context, a, b) => Center(
                    child: Text(
                      "Image cannot be loaded",
                      style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                )
              : Container(),
          widget.doc['link'] != "" ? SizedBox(height: 15) : Container(),
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
                            fontWeight: FontWeight.w700, fontSize: 15),
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
                        .getHttpsCallable(functionName: 'upVotePost')
                        .call(<String, dynamic>{'id': widget.doc.documentID});
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
                        .getHttpsCallable(functionName: 'downVotePost')
                        .call(<String, dynamic>{'id': widget.doc.documentID});
                  }),
              Text(NumberFormat.compact().format(downVotesCount),
                  style: GoogleFonts.ubuntu(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          Divider(
            height: 30,
            thickness: 0.8,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  _buildCommentsList() {
    return comments.length == 0
        ? isLoadingComments == false
            ? Text(
                'No comments',
                style: GoogleFonts.ubuntu(fontSize: 20),
              )
            : Center(child: CircularProgressIndicator())
        : ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection('Users')
                      .document(comments[index].data["commentAuthor"])
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                            snapshot.hasData &&
                                    snapshot.data["photoUrl"] != "" &&
                                    snapshot.data["photoUrl"] != null
                                ? snapshot.data["photoUrl"]
                                : dummyPhotoUrl),
                      ),
                      title: Text(
                          snapshot.hasData && snapshot.data["username"] != ""
                              ? snapshot.data["username"]
                              : 'Loading'),
                      subtitle: Text(comments[index].data["comment"]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          comments[index].data["commentAuthor"] == widget.uid
                              ? IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.trash,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoadingComments = true;
                                    });
                                    await CloudFunctions.instance
                                        .getHttpsCallable(
                                            functionName: 'deleteComment')
                                        .call(<String, dynamic>{
                                      'id': widget.doc.documentID,
                                      'commentId': comments[index].documentID,
                                    });
                                    getComments();
                                    setState(() {
                                      comments.removeAt(index);
                                    });
                                  })
                              : Container(),
                          IconButton(
                              icon: Icon(
                                FontAwesomeIcons.arrowCircleUp,
                                color:
                                    commentUpVotes[index].contains(widget.uid)
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                              onPressed: () {
                                CloudFunctions.instance
                                    .getHttpsCallable(
                                        functionName: 'upVoteComment')
                                    .call(<String, dynamic>{
                                  'id': widget.doc.documentID,
                                  'commentId': comments[index].documentID,
                                });
                                setState(() {
                                  if (commentUpVotes[index]
                                      .contains(widget.uid)) {
                                    commentUpVotes[index].remove(widget.uid);
                                  } else {
                                    commentUpVotes[index].add(widget.uid);
                                  }
                                });
                              }),
                          Text(NumberFormat.compact()
                              .format(commentUpVotes[index].length))
                        ],
                      ),
                    );
                  });
            },
            separatorBuilder: (context, index) => Divider(),
          );
  }

  _buildCommentField() {
    return TextField(
      controller: commentController,
      decoration: InputDecoration(
        hintText: 'Post a Comment ...',
        hintStyle: GoogleFonts.ubuntu(),
        fillColor: Colors.white,
        filled: true,
        suffixIcon: IconButton(
          icon: Icon(FontAwesomeIcons.comments),
          onPressed: () async {
            String comment = commentController.text;
            if (comment.isNotEmpty) {
              commentController.clear();
              setState(() {
                isLoadingComments = true;
              });
              await CloudFunctions.instance
                  .getHttpsCallable(functionName: 'addComment')
                  .call(<String, dynamic>{
                'id': widget.doc.documentID,
                'comment': comment,
              });
              getComments();
            }
          },
        ),
      ),
    );
  }
}
