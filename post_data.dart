
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class postdata extends StatefulWidget {
  const postdata({super.key});

  @override
  State<postdata> createState() => _postdataState();
}

class _postdataState extends State<postdata> {
  @override
  TextEditingController nameController=TextEditingController();
  TextEditingController titleController=TextEditingController();
  TextEditingController marksController=TextEditingController();
  TextEditingController departmentController=TextEditingController();
  Future<void> funpost(String name, String courseTitle, String department, int marks) async {
    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/post'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'courseTitle': courseTitle,
          'department': department,
          'marks': marks,
        }),
      );

      if (res.statusCode == 200) {
        print('Data posted successfully');
        // ✅ Fields Clear
        nameController.clear();
        titleController.clear();
        departmentController.clear();
        marksController.clear();

        // ✅ Show Message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data Posted Successfully!')),);
      } else {
        print('Failed to post data');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Post Data')),);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Occurred')),
      );
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('post Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              label: Text('Name')
            ),
          ),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
                label: Text('CourseTitle')
            ),
          ),
          TextFormField(
            controller: marksController,
            decoration: InputDecoration(
                label: Text('Marks')
            ),
          ),
          TextFormField(
            controller: departmentController,
            decoration: InputDecoration(
                label: Text('Department')
            ),
          ),
          ElevatedButton(onPressed: (){
           funpost( nameController.text,
               titleController.text,
               departmentController.text,
               int.parse(marksController.text));
          }, child: Text('Submit'))
        ],
      ),
    );
  }
}
