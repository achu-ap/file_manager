import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:filemanager/utils/external_storage.dart';
import 'package:filemanager/screens/open_folder.dart';

class FilesWidget extends StatelessWidget {
  const FilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File manager"),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: FileStorage.getListFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(" Error occured"));
          } else if (snapshot.hasData) {
            List<FileSystemEntity> entries = snapshot.data!;
            return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OpenFolder(
                              currentPath: entries[index].path,
                              folderName: basename(entries[index].path),
                            ),
                          ),
                        );
                      },
                      leading: Icon(entries[index] is Directory ? Icons.folder : Icons.file_open),
                      title: Text(basename(entries[index].path),),
                    ));
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
