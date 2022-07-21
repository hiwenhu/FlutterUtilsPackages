import 'dart:io';

abstract class CloudApi {
  Future<void> saveFile(File file);
  Future<void> deleteFile(File file);
  Future<List> listFile();
}
