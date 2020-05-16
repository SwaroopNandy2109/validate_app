import 'package:flutter/material.dart';
import 'package:validatedapp/tabs/appbar_tabs/Home_bar.dart';
import 'package:validatedapp/tabs/appbar_tabs/Trending_bar.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
          centerTitle: true,
          bottom: TabBar(isScrollable: true, tabs: <Widget>[
            Tab(
              child: Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Trending',
                style: TextStyle(
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
