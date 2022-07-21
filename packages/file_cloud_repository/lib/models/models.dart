import 'dart:io';

class FileCloud {
  FileCloud({required this.file, this.version, this.bConfilct});
  final File file;
  String? version;
  bool? bConfilct;
}
