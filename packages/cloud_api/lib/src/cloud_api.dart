import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class CloudApi {
  bool isAuth();
  Future<void> saveFile(File file);
  Future<void> deleteFile(File file);
  Future<List> listFile();
  Future<String?> download(File file, String cloudFileName);
  Future<String?> upload(File file, String cloudFileName);
  Future<List> downloadStream(String cloudFileName);
}
