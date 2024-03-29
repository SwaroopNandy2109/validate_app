import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validatedapp/services/auth.dart';
import 'package:validatedapp/wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validate App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamProvider.value(
          value: AuthService().user,
          child: Wrapper(
            auth: new AuthService(),
          )),
    );
  }
}
