import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget postContainer(String profileImage, String userName, String category,
    String title, String description) {
  return Container(
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
            ),
            SizedBox(
              width: 20,
            ),
            Text(userName),
            Spacer(
              flex: 1,
            ),
            Text(category),
          ],
        ),
        Divider(
          height: 10,
          thickness: 1,
          color: Colors.black,
        ),
        Row(
          children: <Widget>[
            Text(title),
          ],
        ),
        Divider(
          height: 10,
          thickness: 1,
          color: Colors.black,
        ),
        Row(
          children: <Widget>[
            Text(description),
          ],
        ),
      ],
    ),
  );
}
