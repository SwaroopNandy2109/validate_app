import 'package:flutter/material.dart';


class TextPostPage extends StatefulWidget {
  @override
  _TextPostPageState createState() => _TextPostPageState();
}

class _TextPostPageState extends State<TextPostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a text!'),
      ),
    );
  }
}
