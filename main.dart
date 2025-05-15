import 'package:flutter/material.dart';
import 'package:grade_api_save_data/api_work/API_GET.dart';
import 'package:grade_api_save_data/api_work/post_data.dart';
import 'package:grade_api_save_data/home%20(3).dart';
//import 'screens/add_grade_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grades App',
      debugShowCheckedModeBanner: false,
      home: postdata(),
    );
  }
}
