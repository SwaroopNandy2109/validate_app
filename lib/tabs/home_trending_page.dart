import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatedapp/search_page.dart';
import 'package:validatedapp/tabs/appbar_tabs/Home_bar.dart';
import 'package:validatedapp/tabs/appbar_tabs/Trending_bar.dart';

class HomeTrendingPage extends StatefulWidget {
  @override
  _HomeTrendingPageState createState() => _HomeTrendingPageState();
}

class _HomeTrendingPageState extends State<HomeTrendingPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Posts',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
              icon: Icon(Icons.search),
            )
          ],
          centerTitle: true,
          bottom: TabBar(isScrollable: true, tabs: <Widget>[
            Tab(
              child: Text(
                'Home',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Trending',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ]),
        ),
        body: TabBarView(children: <Widget>[
          HomeBarPage(),
          TrendingBarPage(),
        ]),
      ),
    );
  }
}
