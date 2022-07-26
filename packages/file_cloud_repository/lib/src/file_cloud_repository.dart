import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_api/cloud_api.dart';
import 'package:file_cloud_repository/models/models.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FileSyncOper { save, delete }

class FileCloudNotFoundException implements Exception {}

class FileCloudOff implements Exception {}

class FileCloudRepository<CA extends CloudApi> {
  FileCloudRepository({
    required this.localFileRoot,
    required this.cloudApi,
    required this.useCloud,
    String? cloudFileRoot,
  }) {
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
    this.cloudFileRoot = cloudFileRoot ?? basename(localFileRoot.path);
  }
  final CA cloudApi;
  final _filesStreamController =
      BehaviorSubject<List<FileCloud>>.seeded(const []);
  final List<FileCloud> localFiles = [];
  final Map<FileSyncOper, List<FileCloud>> needSyncFiles = {
    FileSyncOper.save: [],
    FileSyncOper.delete: [],
  };

  final Directory localFileRoot;
  late final String cloudFileRoot;

  bool useCloud;

  bool get canUseCloud => useCloud && cloudApi.isAuth();

  void close() {
    _filesStreamController.close();
  }

  File newFile(String fileName) {
    var originPath = '${localFileRoot.path}/$fileName';
    var path = originPath;
    int postfix = 1;
    while (
        localFiles.indexWhere((element) => element.file.path == path) != -1) {
      path = '$originPath (${postfix++})';
    }
    return File(path);
  }

  String localFileVersionKey(File file) {
    return '${file.path}_v';
  }

  Future<void> refresh() async {
    try {
      localFiles.clear();
      var sp = await SharedPreferences.getInstance();

      await for (var data in localFileRoot.list()) {
        if (data is File) {
          localFiles.add(FileCloud(
            file: data,
            version: getFileVersion(
              sp.getString(localFileVersionKey(data)),
            ),
            cloudVersion: -1,
          ));
        }
      }
      // subDir.list().listen((data) {
      //   if (data is File) {

      //   }
      // });

      // _filesStreamController.add([
      //   FileCloud(
      //     file: File('ssssss'),
      //   )
      // ]);

      // Future.delayed(Duration(seconds: 3))
      //     .then((value) => _filesStreamController.add([
      //           FileCloud(
      //             file: File('atatstst'),
      //           )
      //         ]));

      //_filesStreamController.add(localFiles);
      // cloudApi.listFile().then(onCloudFiles).onError((e, st) {
      //   _filesStreamController.add(const []);
      //   log(e.toString(), stackTrace: st);
      // });
      if (canUseCloud) {
        await loadFromCloud();
      } else {
        _filesStreamController.add(localFiles);
      }
    } catch (e, st) {
      _filesStreamController.add(localFiles);
      log(e.toString(), stackTrace: st);
    }
  }

  Future<void> loadFromCloud() async {
    var cloudfiles = await cloudApi.listFile(cloudFileRoot);
    onCloudFiles(cloudfiles);
  }

  void onCloudFiles(List files) {
    for (var cloudFile in files) {
      if (cloudFile is drive.File) {
        int index = localFiles.indexWhere(
            (element) => basename(element.file.path) == cloudFile.name);
        var cloudVersion = getFileVersion(cloudFile.version);
        if (index != -1) {
          // if (localFile.version > getCloudVersion(nativeFile.version)) {
          //   needSyncFiles[FileSyncOper.save]?.add(localFile);
          // }
          localFiles[index] = localFiles[index].copyWith(
            // version: cloudVersion, 需要同步，現在不能更新version
            cloudFileId: cloudFile.id ?? '',
            cloudVersion: cloudVersion,
          );
        } else if (cloudFile.name != null) {
          localFiles.add(FileCloud(
            file: File('${localFileRoot.path}/${cloudFile.name}'),
            // version: cloudVersion, 需要同步，現在不能更新version
            cloudFileId: cloudFile.id ?? '',
            cloudVersion: cloudVersion,
          ));
        }
      }
    }

    for (var i = 0; i < localFiles.length; i++) {
      var localFile = localFiles[i];
      if (localFile.cloudVersion == -1) {
        localFiles[i] = localFiles[i].copyWith(cloudVersion: 0); //云上没有这些文件
      }
    }

    _filesStreamController.add(localFiles);
  }

  int getFileVersion(String? version) {
    return int.tryParse(version ?? '1') ?? 1;
  }

  Stream<List<FileCloud>> getFiles() =>
      _filesStreamController.asBroadcastStream();

  Future saveFile(File file) async {
    // final files = [..._filesStreamController.value];
    // final index = files.indexWhere((t) => t.file.path == file.path);
    // if (index >= 0) {
    //   files[index] = files[index].copyWith(
    //     file: file,
    //     version: files[index].version + 1,
    //   );
    // } else {
    //   files.add(FileCloud(
    //     file: file,
    //     version: 1,
    //   ));
    // }

    final index = localFiles.indexWhere((t) => t.file.path == file.path);
    if (index >= 0) {
      localFiles[index] = localFiles[index].copyWith(
        file: file,
        version: localFiles[index].version + 1,
      );
    } else {
      localFiles.add(FileCloud(
        file: file,
        version: 1,
      ));
    }

    needSyncFiles[FileSyncOper.save]?.add(FileCloud(file: file));

    _filesStreamController.add(localFiles);

    // cloudApi.saveFile(file);
  }

  Future deleteFile(File file) async {
    // final files = [..._filesStreamController.value];
    // final index = files.indexWhere((t) => t.file.path == file.path);
    // if (index == -1) {
    //   throw TodoNotFoundException();
    // } else {

    final index = localFiles.indexWhere((t) => t.file.path == file.path);

    if (index >= 0) {
      var sp = await SharedPreferences.getInstance();
      var cloudFileId = localFiles[index].cloudFileId;
      var localFile = localFiles[index].file;
      sp.remove(localFileVersionKey(localFile));
      localFile.delete();

      localFiles.removeAt(index);
      _filesStreamController.add(localFiles);

      needSyncFiles[FileSyncOper.delete]?.add(FileCloud(file: file));
      needSyncFiles[FileSyncOper.save]
          ?.removeWhere((element) => element.file == file);
      if (useCloud) {
        cloudApi.deleteFile(cloudFileRoot, cloudFileId);
      }
    }
  }

  // Future<FileCloud> download(FileCloud fileCloud) async {
  //   if (!useCloud) {
  //     throw FileCloudOff();
  //   }
  //   var cloudVersion = await cloudApi.download(
  //     fileCloud.file,
  //     fileCloud.cloudFileId,
  //   );
  //   var fc = fileCloud.copyWith(
  //     version: getFileVersion(cloudVersion),
  //   );

  //   final index =
  //       localFiles.indexWhere((t) => t.file.path == fileCloud.file.path);
  //   if (index >= 0) {
  //     localFiles[index] = fc;
  //   } else {
  //     localFiles.add(fc);
  //   }
  //   return fc;
  // }

  Stream<dynamic> downloadStream(FileCloud fileCloud) async* {
    if (!useCloud) {
      throw FileCloudOff();
    }

    if (!cloudApi.isAuth()) {
      yield null;
    }

    var result =
        await cloudApi.downloadStream(cloudFileRoot, fileCloud.cloudFileId);
    assert(result.length >= 3);
    Stream<List<int>>? stream = result[0];
    int length = int.tryParse(result[1].toString()) ?? 1;
    String? cloudVersion = result[2];
    if (stream != null) {
      List<int> dataStore = [];
      await for (var data in stream) {
        dataStore.insertAll(dataStore.length, data);
        yield dataStore.length / length;
      }
      log("Task Done");
      await fileCloud.file.writeAsBytes(dataStore);
      log("File saved at ${fileCloud.file.path}");
      var cv = getFileVersion(cloudVersion);
      var fc = fileCloud.copyWith(
        version: cv,
        cloudVersion: cv,
      );

      var sp = await SharedPreferences.getInstance();
      sp.setString(localFileVersionKey(fileCloud.file), cv.toString());

      final index =
          localFiles.indexWhere((t) => t.file.path == fileCloud.file.path);
      if (index >= 0) {
        localFiles[index] = fc;
      } else {
        localFiles.add(fc);
      }
      yield fc;
    }
    yield null;
  }

  Future<FileCloud?> upload(FileCloud fileCloud) async {
    if (!useCloud) {
      throw FileCloudOff();
    }

    if (!cloudApi.isAuth()) {
      return null;
    }

    var cloudFileInfo = await cloudApi.upload(
        cloudFileRoot, fileCloud.file, fileCloud.cloudFileId);
    if (cloudFileInfo.isEmpty) {
      return null;
    }
    int cloudVersion = getFileVersion(cloudFileInfo[1]);
    var sp = await SharedPreferences.getInstance();
    sp.setString(localFileVersionKey(fileCloud.file), cloudVersion.toString());
    var fc = fileCloud.copyWith(
        version: cloudVersion,
        cloudFileId: cloudFileInfo[0],
        cloudVersion: cloudVersion);
    final index =
        localFiles.indexWhere((t) => t.file.path == fileCloud.file.path);
    if (index >= 0) {
      localFiles[index] = fc;
    } else {
      localFiles.add(fc);
    }
    return fc;
  }

  Future<FileCloud?> localFileReCloud(FileCloud fileCloud) async {
    final index =
        localFiles.indexWhere((t) => t.file.path == fileCloud.file.path);
    if (index >= 0) {
      List<String?> result = await cloudApi.getFileMetadata(
          cloudFileRoot, basename(fileCloud.file.path));
      if (result.length >= 2) {
        localFiles[index] = localFiles[index].copyWith(
          cloudFileId: result[0],
          cloudVersion: getFileVersion(result[1]),
        );
        return localFiles[index];
      }
    }
    return null;
  }
}
