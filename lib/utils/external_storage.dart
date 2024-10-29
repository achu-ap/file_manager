import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    var eStatus = await Permission.manageExternalStorage.status;
    if (!eStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/download");
    } else {
      _directory = await getApplicationCacheDirectory();
    }
    final exPath = _directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> getExternalStoragePath() async {
    var status = await Permission.storage.status;
    var eStatus = await Permission.manageExternalStorage.status;
    if (!eStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0");
    } else {
      _directory = await getApplicationCacheDirectory();
    }
    final exPath = _directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<File> writeCounter(String bytes, String name) async {
    final path = await getExternalDocumentPath();
    File file = File("$path/$name");
    return file.writeAsString(bytes);
  }

  static Future<List> listFiles() async {
    final path = await getExternalDocumentPath();
    return Directory(path).listSync();
  }

  static Future<List<FileSystemEntity>> getListFiles() async {
    final path = await getExternalStoragePath();
    return Directory(path).listSync();
  }
}
