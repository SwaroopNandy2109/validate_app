import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validatedapp/models/user.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final Function deletePost;
  final List upVotes;
  final List downVotes;

  PostCard({this.doc, this.deletePost, this.upVotes, this.downVotes});

  @override
  _PostCardState createState() => _PostCardState(this.upVotes, this.downVotes);
}

class _PostCardState extends State<PostCard> {
  List upVotes;
  List downVotes;

  _PostCardState(this.upVotes, this.downVotes);

  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    var date = widget.doc["timestamp"].toDate();
    int upVotesCount = upVotes.length;
    int downVotesCount = downVotes.length;
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
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
                  Spacer(),
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          showOptions(context, widget.doc["author"], user.uid);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          size: 35,
                        ),
                      )
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
                    color: upVotes.contains(user.uid) == true
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onPressed: () async {
                    setState(() {
                      upVotes.contains(user.uid)
                          ? upVotes.remove(user.uid)
                          : upVotes.add(user.uid);
                      if (downVotes.contains(user.uid)) {
                        downVotes.remove(user.uid);
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
                    color:
                        downVotes.contains(user.uid) ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    setState(() {
                      downVotes.contains(user.uid)
                          ? downVotes.remove(user.uid)
                          : downVotes.add(user.uid);
                      if (upVotes.contains(user.uid)) {
                        upVotes.remove(user.uid);
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
        ],
      ),
    );
  }

  showOptions(parentContext, String authorUid, String userUid) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              "Options",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              authorUid != userUid
                  ? SimpleDialogOption(
                      child: Text(
                        "Report",
                        style: GoogleFonts.ubuntu(),
                      ),
                      onPressed: () {},
                    )
                  : SimpleDialogOption(
                      child: Text(
                        "Delete",
                        style: GoogleFonts.ubuntu(),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.deletePost();
                      },
                    ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: GoogleFonts.ubuntu(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
}
