import 'dart:async';
import 'dart:io';
import 'package:file_cloud_repository/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:cloud_api/cloud_api.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:collection/collection.dart';
import 'dart:developer';

enum FileSyncOper { save, delete }

class FileCloudRepository<CA extends CloudApi> {
  FileCloudRepository({required this.cloudApi}) {
    // refresh();
    // Timer.periodic(const Duration(seconds: 5), (_) {
    //   var files = needSyncFiles[FileSyncOper.save];
    //   files?.forEach((element) {
    //     cloudApi
    //         .saveFile(element.file)
    //         .then((value) => files?.remove(element))
    //         .onError((error, stackTrace) {
    //       log(error.toString());
    //       return null;
    //     });
    //   });
    //   files = needSyncFiles[FileSyncOper.delete];
    //   files?.forEach((element) {
    //     cloudApi
    //         .deleteFile(element.file)
    //         .then((value) => files?.remove(element))
    //         .onError((error, stackTrace) {
    //       log(error.toString());
    //       return null;
    //     });
    //   });
    // });
  }
  final CA cloudApi;
  final _filesStreamController =
      BehaviorSubject<List<FileCloud>>.seeded(const []);
  final List<FileCloud> localFiles = [];
  final Map<FileSyncOper, List<FileCloud>> needSyncFiles = {
    FileSyncOper.save: [],
    FileSyncOper.delete: [],
  };

  void close() {
    _filesStreamController.close();
  }

  Future<void> refresh() async {
    try {
      var directory = await getApplicationSupportDirectory();

      bool exists = await directory.exists();
      var subDirName = 'tmp';
      // if (exists) {
      var subDir = Directory('${directory.path}/$subDirName');
      subDir = await subDir.create();
      // }

      localFiles.clear();
      await for (var data in subDir.list()) {
        if (data is File) {
          localFiles.add(FileCloud(
            file: data,
          ));
        }
      }
      // subDir.list().listen((data) {
      //   if (data is File) {

      //   }
      // });

      _filesStreamController.add(localFiles);

      cloudApi.listFile().then((files) {
        for (var nativeFile in files) {
          if (nativeFile is drive.File) {
            FileCloud? localFile = localFiles.firstWhereOrNull(
                (element) => basename(element.file.path) == nativeFile.name);
            if (localFile != null) {
              if (localFile.version > getCloudVersion(nativeFile.version)) {
                needSyncFiles[FileSyncOper.save]!.add(localFile);
              }
            } else {
              localFiles.add(FileCloud(
                file: File(nativeFile.name ?? 'tmp'),
                version: int.tryParse(nativeFile.version!) ?? 1,
              ));
            }
          }
        }
        _filesStreamController.add(localFiles);
      });
    } catch (_) {
      _filesStreamController.add(const []);
    }
  }

  int getCloudVersion(String? version) {
    return int.tryParse(version ?? '1') ?? 1;
  }

  Stream<List<FileCloud>> getFiles() =>
      _filesStreamController.asBroadcastStream();

  Future saveFile(File file) async {
    final files = [..._filesStreamController.value];
    final index = files.indexWhere((t) => t.file.path == file.path);
    if (index >= 0) {
      files[index] = files[index].copyWith(
        file: file,
        version: files[index].version + 1,
      );
    } else {
      files.add(FileCloud(
        file: file,
        version: 1,
      ));
    }

    needSyncFiles[FileSyncOper.save]?.add(FileCloud(file: file));

    _filesStreamController.add(files);

    cloudApi.saveFile(file);
  }

  Future deleteFile(File file) async {
    final files = [..._filesStreamController.value];
    final index = files.indexWhere((t) => t.file.path == file.path);
    // if (index == -1) {
    //   throw TodoNotFoundException();
    // } else {
    if (index >= 0) {
      files.removeAt(index);
      _filesStreamController.add(files);
      needSyncFiles[FileSyncOper.delete]?.add(FileCloud(file: file));
      needSyncFiles[FileSyncOper.save]
          ?.removeWhere((element) => element.file == file);
    }
    cloudApi.deleteFile(file);
  }

  Future<void> download(FileCloud fileCloud, VoidCallback onDone) async {
    await cloudApi.download(fileCloud.file, fileCloud.cloudFileId, onDone: onDone);
    // return fileCloud.copyWith(
    //   version: fileCloud.cloudVersion,
    // );
  }

  Future<FileCloud> upload(FileCloud fileCloud) async {
    int cloudVersion = getCloudVersion(
        await cloudApi.upload(fileCloud.file, fileCloud.cloudFileId));
    return fileCloud.copyWith(
        version: cloudVersion, cloudVersion: cloudVersion);
  }
}
