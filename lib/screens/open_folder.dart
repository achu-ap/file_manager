import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:filemanager/models/global.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:filemanager/screens/image.dart';
import 'package:filemanager/utils/external_storage.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OpenFolder extends StatefulWidget {
  OpenFolder({
    Key? key,
    required this.currentPath,
    required this.folderName,
  }) : super(key: key);

  final String currentPath;
  final String folderName;

  @override
  State<OpenFolder> createState() => _OpenFolderState();
}

class _OpenFolderState extends State<OpenFolder> {
  Future<List<FileSystemEntity>> getFolder() async {
    return Directory(widget.currentPath).listSync();
  }

  String basePath(String path) {
    final split = path.split("/");
    split.removeAt(split.length - 1);
    return split.join("/");
  }

  bool isImage(FileSystemEntity entity) {
    return entity is File &&
        ['.jpg', '.jpeg', '.png', '.gif'].contains(extension(entity.path));
  }

  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final global = context.watch<Global>();
    return Scaffold(
      appBar: AppBar(actions: [
        global.selected.isNotEmpty
            ? IconButton(
                onPressed: () async {
                  final canDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        AlertDialog(title: Text("Are you sure ?"), actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("Delete")),
                    ]),
                  );
                  if (canDelete ?? false) {
                    global.selected.forEach((file) {
                      File(file).deleteSync();
                    });
                    global.unselectFile();
                  }
                },
                icon: Icon(Icons.delete),
              )
            : SizedBox(),
        global.selected.isNotEmpty
            ? IconButton(
                onPressed: () async {
                  final canEdit = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Container(
                            color: Colors.blue[100],
                            width: 250,
                            child: TextField(
                              controller: name,
                              decoration: InputDecoration(
                                hintText: basename(global.selected.first),
                              ),
                            )),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text("Rename")),
                        ]),
                  );
                  if (canEdit ?? false) {
                    global.selected.forEach((file) {
                      File(file).renameSync("${basePath(file)}/${name.text}");
                      name.clear();
                    });
                    global.unselectFile();
                  }
                },
                icon: Icon(Icons.edit))
            : SizedBox(),
      // global.selected.isNotEmpty
      //       ? IconButton(
      //           onPressed: () async {
      //             String predefinedDirectory = "/storage/emulated/0/YourAppFolder";
      //             Directory(predefinedDirectory).createSync(recursive: true);

      //             for (String filePath in global.selected) {
      //               File originalFile = File(filePath);
      //               String fileName = basename(filePath);
      //               String newFilePath = join(predefinedDirectory, fileName);

      //               try {
      //                 await originalFile.copy(newFilePath);
      //                 print("File copied to: $newFilePath");
      //               } catch (e) {
      //                 print("Error copying file: $e");
      //               }
      //             }
      //             global.unselectFile();
      //           },
      //           icon: Icon(Icons.copy),
      //         )
      //       : SizedBox(),
      if (global.selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () async {
                
                final imageFiles = global.selected
                    .where((file) => isImage(File(file)))
                    .toList();

                if (imageFiles.isNotEmpty) {
              
                  final firstImagePath = imageFiles.first;
                  await Clipboard.setData(ClipboardData(text: firstImagePath));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image path copied to clipboard')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No images selected for copying.")),
                  );
                }
              },
            ),
            IconButton(
            icon: const Icon(Icons.paste),
            onPressed: () async {
              final clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData?.text != null) {
                final newPath = join(current, basename(clipboardData!.text!));
                try {
                  File(clipboardData.text!).copySync(newPath);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image pasted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to paste image')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No image path found in clipboard.")),
                );
              }
            },
          ),



        global.selected.isNotEmpty
            ? IconButton(onPressed: () async {
              final result = await Share.shareXFiles([...global.selected.map((e)=> XFile(e))],text: "these are good images");
            }, icon: Icon(Icons.share))
            : SizedBox(),
      ]),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: getFolder(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error occurred"),
            );
          } else if (snapshot.hasData) {
            List<FileSystemEntity> entries = snapshot.data!;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  onLongPress: () {
                    global.selectFile(entries[index].path);
                  },
                  onTap: () {
                    if (global.selected.isNotEmpty) {
                      global.selectFile(entries[index].path);
                      return;
                    }
                    if (entry is Directory) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OpenFolder(
                            currentPath: entry.path,
                            folderName: basename(entry.path),
                          ),
                        ),
                      );
                    } else if (entry is File && isImage(entry)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageWidget(path: entry.path),
                        ),
                      );
                    }
                  },
                  trailing: global.selected.isNotEmpty
                      ? Radio(
                          value: true,
                          groupValue:
                              global.selected.contains(entries[index].path),
                          onChanged: (_) {})
                      : SizedBox(),
                  leading: Hero(
                    tag: basename(entry.path),
                    child: entry is Directory
                        ? const Icon(Icons.folder)
                        : (isImage(entry)
                            ? Image.file(
                                File(entry.path),
                                height: double.infinity,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.file_open)),
                  ),
                  title: Text(basename(entry.path)),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
