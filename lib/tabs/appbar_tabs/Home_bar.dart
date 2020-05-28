import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/constants/post_container.dart';
import 'package:validatedapp/services/postsbloc.dart';

class HomeBarPage extends StatefulWidget {
  @override
  _HomeBarPageState createState() => _HomeBarPageState();
}

class _HomeBarPageState extends State<HomeBarPage> {
  String categoryChoice = 'All';
  PostsBloc postlistbloc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    postlistbloc = PostsBloc();
    postlistbloc.fetchFirstList();
    controller.addListener(_scrollListener);
  }

//  FlatButton.icon(
//  icon: Icon(Icons.arrow_drop_down),
//  label: Text(
//  categoryChoice,
//  style: GoogleFonts.ubuntu(fontSize: 17),
//  ),
//  onPressed: () => showCategoryModal(context),
//  ),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: postlistbloc.postStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data.length) {
                  return CupertinoActivityIndicator();
                }
                return Card(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: postContainer(
                          "https://www.clipartkey.com/mpngs/m/126-1261738_computer-icons-person-login-anonymous-person-icon.png",
                          "userName",
                          snapshot.data[index]["category"],
                          snapshot.data[index]["title"],
                          snapshot.data[index]["description"])),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                style: GoogleFonts.ubuntu(fontSize: 28),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
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
