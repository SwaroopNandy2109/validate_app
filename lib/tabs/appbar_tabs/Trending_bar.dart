import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/post_container.dart';
import 'package:validatedapp/services/postsbloc.dart';

class TrendingBarPage extends StatefulWidget {
  @override
  _TrendingBarPageState createState() => _TrendingBarPageState();
}

class _TrendingBarPageState extends State<TrendingBarPage> {
  String categoryChoice = 'All';
  PostsBloc postlistbloc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    postlistbloc = PostsBloc();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    postlistbloc.fetchFirstList();
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
            StreamBuilder<List<DocumentSnapshot>>(
              stream: postlistbloc.postStream,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length + 1,
                      controller: controller,
                      itemBuilder: (context, index) {
                        if (index >= snapshot.data.length) {
                          return CupertinoActivityIndicator();
                        }
                        return PostCard(doc: snapshot.data[index]);
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error}',
                      style: GoogleFonts.ubuntu(fontSize: 28),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      postlistbloc.fetchNextPosts();
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
      onTap: () {
        setState(() {
          categoryChoice = title;
        });
        Navigator.of(context).pop();
      },
    );
  }
}
