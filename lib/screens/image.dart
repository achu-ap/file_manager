import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';

class ImageWidget extends StatelessWidget {
  ImageWidget({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(basename(path)),
      ),
      body: Hero(
        tag: basename(path),
        child: Image.file(
          File(path),
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
