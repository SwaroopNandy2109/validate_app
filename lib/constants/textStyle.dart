import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle styleText = GoogleFonts.ubuntu(
  fontSize: 18.0,
  color: Colors.grey,
);

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pinkAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
    ));
