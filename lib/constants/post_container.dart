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
import 'package:url_launcher/url_launcher.dart';
import 'package:validatedapp/constants/shared.dart';
import 'package:intl/intl.dart';
import 'package:validatedapp/tabs/view_post.dart';

class PostCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final Function deletePost;
  final List upVotes;
  final List downVotes;
  final String uid;
  final Function refresh;

  PostCard(
      {this.doc,
      this.deletePost,
      this.upVotes,
      this.downVotes,
      this.uid,
      this.refresh});

  @override
  _PostCardState createState() => _PostCardState(this.upVotes, this.downVotes);
}

class _PostCardState extends State<PostCard> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List upVotes;
  List downVotes;
  String _currentTitle = "";
  String _currentCategory = "";
  String _currentDescription = "";
  String _currentLink = "";
  List<String> categories = [
    'Politics',
    'Sports',
    'Economy',
    'Business',
    'Entertainment'
  ];

  _PostCardState(this.upVotes, this.downVotes);

  final String dummyPhotoUrl =
      'https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png';

  @override
  Widget build(BuildContext context) {
    var date = widget.doc["timestamp"].toDate();
    int upVotesCount = upVotes.length;
    int downVotesCount = downVotes.length;
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewPost(
                  doc: widget.doc,
                  upVotes: upVotes,
                  downVotes: downVotes,
                  uid: widget.uid,
                )));
        widget.refresh();
      },
      child: Container(
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
                            showOptions(
                                context, widget.doc["author"], widget.uid);
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
              authorUid == userUid
                  ? SimpleDialogOption(
                      child: Text(
                        "Edit",
                        style: GoogleFonts.ubuntu(),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showEditModalSheet(context);
                      },
                    )
                  : Container(),
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

  showEditModalSheet(parentContext) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: parentContext,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              autovalidate: true,
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Edit Post',
                        style: GoogleFonts.ubuntu(
                            fontSize: 25, fontWeight: FontWeight.w800),
                      ),
                    ),
                    SizedBox(height: 18),
                    DropdownButtonFormField(
                      decoration: textInputDecoration,
                      value: _currentCategory.isEmpty
                          ? widget.doc["category"]
                          : _currentCategory,
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            '$cat',
                            style: GoogleFonts.ubuntu(),
                          ),
                        );
                      }).toList(),
                      hint: Text(
                        'Choose a category',
                        style: GoogleFonts.ubuntu(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _currentCategory = val;
                        });
                      },
                      validator: (val) => (_currentCategory == null ||
                                  _currentCategory.isEmpty) &&
                              widget.doc["category"].isEmpty
                          ? 'Please choose a category'
                          : null,
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      maxLength: 50,
                      initialValue: widget.doc["title"],
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Edit your title...',
                        hintStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                      ),
                      validator: (val) =>
                          val.isEmpty ? "Title can'\'t be empty" : null,
                      onChanged: (val) => _currentTitle = val.trim(),
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      maxLines: 10,
                      initialValue: widget.doc["description"],
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Edit your description...',
                        hintStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                      ),
                      validator: (val) =>
                          val.isEmpty ? "Description can'\'t be empty" : null,
                      onChanged: (val) => _currentDescription = val.trim(),
                    ),
                    SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom * 0.3),
                      child: TextFormField(
                        initialValue: widget.doc["link"],
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Edit your link...',
                          hintStyle:
                              GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                        ),
                        onChanged: (val) => _currentLink = val.trim(),
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: RaisedButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        color: Colors.deepPurple,
                        onPressed: () async {
                          await validateAndSubmitEditForm();
                          Navigator.pop(context);
                          widget.refresh();
                        },
                        child: Text(
                          'Finish Edit',
                          style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))));
  }

  validateAndSubmitEditForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    await CloudFunctions.instance
        .getHttpsCallable(functionName: 'updatePost')
        .call(<String, dynamic>{
      'id': widget.doc.documentID,
      'title': _currentTitle.isEmpty ? widget.doc["title"] : _currentTitle,
      'description': _currentDescription.isEmpty
          ? widget.doc["description"]
          : _currentDescription,
      'link': _currentLink.isEmpty ? widget.doc["link"] : _currentLink,
      'category':
          _currentCategory.isEmpty ? widget.doc["category"] : _currentCategory,
    });
  }
}
