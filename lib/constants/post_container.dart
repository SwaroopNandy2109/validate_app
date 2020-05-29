import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validatedapp/models/user.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot doc;
  final Function deletePost;

  PostCard({this.doc, this.deletePost});

  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    var date = doc["timestamp"].toDate();
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: Column(
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('Users')
                .document(doc["author"])
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
                          showOptions(context, doc["author"], user.uid);
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
              Text(
                doc["title"],
                style: GoogleFonts.ubuntu(
                    fontSize: 25, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: <Widget>[
              Expanded(
                child: AutoSizeText(
                  doc["description"],
                  minFontSize: 18,
                  overflow: TextOverflow.ellipsis,
                  maxFontSize: double.infinity,
                  maxLines: 5,
                ),
              ),
            ],
          ),
          doc["type"] == 'Image'
              ? SizedBox(height: 20)
              : SizedBox(
                  height: 0,
                ),
          doc["type"] == 'Image'
              ? Container(
                  height: 320.0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(doc["mediaURL"]),
                        ),
                      ),
                    ),
                  ),
                )
              : Text(''),
          doc['type'] == 'link'
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Linkify(
                        text: doc["link"],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w700, fontSize: 15),
                        maxLines: 2,
                        onOpen: (url) async {
                          try {
                            await launch(doc["link"]);
                          } catch (e) {
                            print('Couldn\'t Launch Link because \n $e');
                          }
                        },
                      ),
                    ),
                  ],
                )
              : Text("")
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
                        deletePost();
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
