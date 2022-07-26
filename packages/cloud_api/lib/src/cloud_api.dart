import 'dart:io';

abstract class CloudApi {
  bool isAuth();
  // Future<void> saveFile(File file);
  Future<void> deleteFile(String folderName, String cloudFileId);
  Future<List> listFile(String folderName);
  // Future<String?> download(File file, String cloudFileId);
  Future<List<String?>> upload(
      String folderName, File file, String cloudFileId);
  Future<List> downloadStream(String folderName, String cloudFileId);
  Future<List<String?>> getFileMetadata(String folderName, String fileName);
}
