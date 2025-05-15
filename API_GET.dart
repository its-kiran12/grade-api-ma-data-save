import 'dart:convert';
import 'Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class showdata_api extends StatefulWidget {
  const showdata_api({super.key});

  @override
  State<showdata_api> createState() => _showdata_apiState();
}

class _showdata_apiState extends State<showdata_api> {
  @override
  List<Model> datashow=[];
  Future<List<Model>> funget() async{
    final res= await http.get(Uri.parse('http://127.0.0.1:8000/api/get'));
    var data= jsonDecode(res.body.toString());
    if(res.statusCode==200)
      {
        for(Map i in data)
          {
            datashow.add(Model.fromJson(i));
          }
        return datashow;
      }
    else
      {
        return datashow;
      }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show api data'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
         Expanded(
           child: FutureBuilder(future: funget(),
               builder: (context,snapshot){
             if(!snapshot.hasData)
               {
                 return Text('loading..');
               }
             else
               {
                 return ListView.builder(
                 itemCount: datashow.length,
                 itemBuilder: (context,index){
                   return Card(
                     child: Column(
                       children: [
                        Text(datashow[index].name ??''),
                         Text(datashow[index].courseTitle!)
                       ],
                     ),
                   );
                 });
               }
               }),
         )
        ],
      ),
    );
  }
}
