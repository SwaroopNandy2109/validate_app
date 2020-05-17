import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBarPage extends StatefulWidget {
  @override
  _HomeBarPageState createState() => _HomeBarPageState();
}

class _HomeBarPageState extends State<HomeBarPage> {
  String categoryChoice = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        FlatButton.icon(
          icon: Icon(Icons.arrow_drop_down),
          label: Text(
            categoryChoice,
            style: GoogleFonts.ubuntu(fontSize: 17),
          ),
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
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
          },
        ),
      ],
    ));
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
