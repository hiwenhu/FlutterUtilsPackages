import 'dart:io';

import 'package:equatable/equatable.dart';

class FileCloud extends Equatable {
  const FileCloud({
    required this.file,
    this.cloudFileId = '',
    this.version = 0,
    this.cloudVersion = 0,
  });
  final File file;
  final int version;
  final String cloudFileId;
  final int cloudVersion;

  FileCloud copyWith(
      {File? file, String? cloudFileId, int? version, int? cloudVersion}) {
    return FileCloud(
      file: file ?? this.file,
      version: version ?? this.version,
      cloudFileId: cloudFileId ?? this.cloudFileId,
      cloudVersion: cloudVersion ?? this.cloudVersion,
    );
  }

  bool get needUploading => cloudVersion >= 0 && version > cloudVersion;

  bool get needDownloading => cloudVersion >= 0 && version < cloudVersion;

  bool get needGetFromCloud => cloudVersion == -1;

  @override
  List get props => [file, version, cloudVersion, cloudFileId];
}
