import 'package:flutter/material.dart';

import 'package:edison/home_page.dart';

class EdisonApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edison Application',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomePage(title: 'Edison'),
    );
  }
}