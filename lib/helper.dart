import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.pdf');
  }

  static Future<File> writeFile(List<int> bytes, String fileName) async {
    final file = await _localFile(fileName);
    final result = await file.writeAsBytes(bytes);
    debugPrint(result.path);
    return result;
  }

  static Future<File> readFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      return file;
    } catch (e) {
      throw 'Could not get file path';
    }
  }

  static Future<String> loadAsset(String asset) async {
    debugPrint(await rootBundle.loadString(asset));
    return rootBundle.loadString(asset);
  }
}
