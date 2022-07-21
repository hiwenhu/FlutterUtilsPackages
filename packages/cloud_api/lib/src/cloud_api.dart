import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class CloudApi {
  Future<void> saveFile(File file);
  Future<void> deleteFile(File file);
  Future<List> listFile();
  Future<void> download(File file, String cloudFileId, {VoidCallback? onDone});
  Future<String?> upload(File file, String cloudFileId);
}
