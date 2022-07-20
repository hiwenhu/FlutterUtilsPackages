import 'dart:io';

abstract class CloudApi {
  Future<void> saveFile(File file);
  Future<void> deleteFile(String fileName);
  Future<List<File>> listFile();
}
