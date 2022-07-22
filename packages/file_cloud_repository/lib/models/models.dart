import 'dart:io';

import 'package:equatable/equatable.dart';

class FileCloud extends Equatable {
  const FileCloud(
      {required this.file,
      this.cloudFileName = '',
      this.version = 0,
      this.cloudVersion = 0});
  final File file;
  final int version;
  final String cloudFileName;
  final int cloudVersion;

  FileCloud copyWith(
      {File? file, String? cloudFileName, int? version, int? cloudVersion}) {
    return FileCloud(
      file: file ?? this.file,
      version: version ?? this.version,
      cloudFileName: cloudFileName ?? this.cloudFileName,
      cloudVersion: cloudVersion ?? this.cloudVersion,
    );
  }

  bool get needUploading => version > cloudVersion;

  bool get needDownloading => version < cloudVersion;

  @override
  List get props => [file, version, cloudVersion, cloudFileName];
}
