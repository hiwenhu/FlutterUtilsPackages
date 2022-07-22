import 'package:cloud_api/cloud_api.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';
import 'dart:io';
import 'dart:developer';
import 'google_auth_client.dart';

class GoogleDriveCloudApi extends CloudApi {
  GoogleDriveCloudApi(this.googleSignIn);
  final GoogleSignIn googleSignIn;
  GoogleSignInAccount? get account => googleSignIn.currentUser;

  // Future<GoogleSignInAccount?> getAccount() async {
  //   if (account == null) {
  //     final googleSignIn =
  //         GoogleSignIn.standard(scopes: [drive.DriveApi.driveAppdataScope]);
  //     account = await googleSignIn.signInSilently();
  //   }
  //   return account;
  // }

  @override
  Future deleteFile(File file) async {
    // await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      final fileName = basename(file.path);
      var fileList = await driveApi.files.list(
          q: "name = '$fileName' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');

      var fileId =
          fileList.files?.isNotEmpty == true ? fileList.files!.first.id : null;
      if (fileId != null) {
        driveApi.files.delete(fileId);
      }
    }
  }

  @override
  Future<List<drive.File>> listFile() async {
    // await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      var fileList = await driveApi.files.list(
          q: "'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id,name,version)');

      // var directory = await getApplicationSupportDirectory();

      return fileList.files ??
          //         ?.map((e) => File('${directory.path}/${e.name}'))
          //         .toList() ??
          [];
    }
    return [];
  }

  @override
  Future<drive.File?> saveFile(File file) async {
    // await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      var driveFile = drive.File();
      driveFile.name = basename(file.path);
      var fileList = await driveApi.files.list(
          q: "name='${driveFile.name}' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');
      drive.Media? media;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.isPhysicalDevice == false) {
          final Stream<List<int>> mediaStream =
              Future.value([105, 106]).asStream().asBroadcastStream();
          media = drive.Media(mediaStream, 2);
        }
      }
      media ??= drive.Media(file.openRead(), await file.length());
      drive.File result;
      if (fileList.files?.isNotEmpty == true &&
          fileList.files!.first.id != null) {
        result = await driveApi.files
            .update(driveFile, fileList.files!.first.id!, uploadMedia: media);
      } else {
        //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
        driveFile.parents = ['appDataFolder'];

        result = await driveApi.files.create(driveFile, uploadMedia: media);
      }
      log("Upload result: $result");
      return result;
    }
    return null;
  }

  @override
  Future<String?> download(
    File file,
    String cloudFileName,
  ) async {
    // await getAccount();
    String? cloudVersion;
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      var fileList = await driveApi.files.list(
          q: "name='$cloudFileName' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id, version)');

      if (fileList.files?.isNotEmpty != true ||
          fileList.files!.first.id == null) {
        throw FileCloudNotFoundException();
      }

      var result = await driveApi.files.get(
        fileList.files!.first.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
        // $fields: 'files(id, version)',
      );
      drive.Media cloudFile = result as drive.Media;
      //  final directory = await getExternalStorageDirectory();
      //  print(directory.path);
      //  final saveFile = File('${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
      try {
        List<int> dataStore = [];
        await for (final data in cloudFile.stream) {
          dataStore.insertAll(dataStore.length, data);
        }
        log("Task Done");
        await file.writeAsBytes(dataStore);
        log("File saved at ${file.path}");
      } catch (e, st) {
        log(e.toString(), stackTrace: st);
        rethrow;
      }

      // cloudFile.stream.listen((data) {
      //   print("DataReceived: ${data.length}");
      //   dataStore.insertAll(dataStore.length, data);
      // }, onDone: () {
      //   print("Task Done");
      //   file.writeAsBytes(dataStore);
      //   if (onDone != null) {
      //     onDone(fileList.files!.first.version);
      //   }
      //   print("File saved at ${file.path}");
      // }, onError: (error) {
      //   print("Some Error");
      // });
      cloudVersion = fileList.files!.first.version;
    }
    return cloudVersion;
  }

  @override
  Future<String?> upload(File file, String cloudFileName) async {
    // await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      var driveFile = drive.File();
      driveFile.name = basename(file.path);
      var fileList = await driveApi.files.list(
          q: "name='$cloudFileName' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');
      drive.Media? media;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.isPhysicalDevice == false) {
          final Stream<List<int>> mediaStream =
              Future.value([105, 106]).asStream().asBroadcastStream();
          media = drive.Media(mediaStream, 2);
        }
      }
      media ??= drive.Media(file.openRead(), await file.length());
      drive.File result;
      if (fileList.files?.isNotEmpty == true &&
          fileList.files!.first.id != null) {
        result = await driveApi.files
            .update(driveFile, fileList.files!.first.id!, uploadMedia: media);
      } else {
        //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
        driveFile.parents = ['appDataFolder'];

        result = await driveApi.files.create(driveFile, uploadMedia: media);
      }
      log("Upload result: $result");
      return result.version;
    }
    return null;
  }

  @override
  Future<List> downloadStream(String cloudFileName) async {
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      var fileList = await driveApi.files.list(
          q: "name='$cloudFileName' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id, version)');

      if (fileList.files?.isNotEmpty != true ||
          fileList.files!.first.id == null) {
        throw FileCloudNotFoundException();
      }

      var result = await driveApi.files.get(
        fileList.files!.first.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
        // $fields: 'files(id, version)',
      );
      drive.Media cloudFile = result as drive.Media;
      //  final directory = await getExternalStorageDirectory();
      //  print(directory.path);
      //  final saveFile = File('${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
      return [cloudFile.stream, cloudFile.length, fileList.files!.first.version];
    }
    return [null, 0];
  }
}
