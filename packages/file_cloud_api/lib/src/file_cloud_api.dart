import 'dart:io';

import 'package:cloud_api/cloud_api.dart';

abstract class FileCloudApi {
  const FileCloudApi({required this.cloudApi});
  final CloudApi cloudApi;

  Stream<List<File>> getFiles();

  Future<void> saveFile(File file);

  Future<void> deleteFile(File file);  
}
