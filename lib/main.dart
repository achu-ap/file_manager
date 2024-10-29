import 'package:filemanager/models/global.dart';
import 'package:filemanager/screens/files.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main(){
  runApp(ChangeNotifierProvider(create: (context)=> Global(),
  child: Filemanager(),));
}
class Filemanager extends StatelessWidget {
  const Filemanager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:FilesWidget() ,
      
    );
  }
}