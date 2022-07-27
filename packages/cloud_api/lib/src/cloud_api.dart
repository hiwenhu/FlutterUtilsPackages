import 'dart:io';

abstract class CloudApi {
  bool isAuth();
  Future<void> init();
  Future<String?> getFolderId(String folderName);
  // Future<void> saveFile(File file);
  Future<void> deleteFile(String? folderId, String folderName, String cloudFileId);
  Future<List> listFile(String? folderId, String folderName);
  // Future<String?> download(File file, String cloudFileId);
  Future<List<String?>> upload(String? folderId, 
      String folderName, File file, String cloudFileId);
  Future<List> downloadStream(String? folderId, String folderName, String cloudFileId);
  Future<List<String?>> getFileMetadata(String? folderId, String folderName, String fileName);
  Future<List<Map>?> getChanges(String? folderId, String folderName);
}
