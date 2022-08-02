import 'package:cloud_api/cloud_api.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  String? startPageToken;
  // Future<GoogleSignInAccount?> getAccount() async {
  //   if (account == null) {
  //     final googleSignIn =
  //         GoogleSignIn.standard(scopes: [drive.DriveApi.driveAppdataScope]);
  //     account = await googleSignIn.signInSilently();
  //   }
  //   return account;
  // }

  @override
  Future deleteFile(
      String? folderId, String folderName, String cloudFileId) async {
    // await getAccount();
    if (account != null) {
      folderId ??= (await getFolder(folderName)).id;
      if (folderId == null) {
        return;
      }
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      // final fileName = basename(file.path);
      // var fileList = await driveApi.files.list(
      //     q: "name = '$fileName' and '${folder.id}' in parents and mimeType != 'application/vnd.google-apps.folder' and trashed = false",
      //     spaces: 'appDataFolder',
      //     $fields: 'files(id)');

      // var fileId =
      //     fileList.files?.isNotEmpty == true ? fileList.files!.first.id : null;
      // if (fileId != null) {
      driveApi.files.delete(cloudFileId);
      // }
    }
  }

  @override
  Future<List<drive.File>> listFile(
    String? folderId,
    String folderName,
  ) async {
    // await getAccount();
    if (account != null) {
      folderId ??= (await getFolder(folderName)).id;
      if (folderId == null) {
        return const [];
      }
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      var fileList = await driveApi.files.list(
          q: "'$folderId' in parents and trashed = false and mimeType != 'application/vnd.google-apps.folder'",
          spaces: 'appDataFolder',
          $fields: 'files(id,name,version)');

      // var directory = await getApplicationSupportDirectory();

      return fileList.files ??
          //         ?.map((e) => File('${directory.path}/${e.name}'))
          //         .toList() ??
          const [];
    }
    return const [];
  }

  // @override
  // Future<drive.File?> saveFile(File file) async {
  //   // await getAccount();
  //   if (account != null) {
  //     final authHeaders = await account!.authHeaders;
  //     final authenticateClient = GoogleAuthClient(authHeaders);
  //     final driveApi = drive.DriveApi(authenticateClient);
  //     var driveFile = drive.File();
  //     driveFile.name = basename(file.path);
  //     var fileList = await driveApi.files.list(
  //         q: "name='${driveFile.name}' and 'appDataFolder' in parents and trashed = false",
  //         spaces: 'appDataFolder',
  //         $fields: 'files(id)');
  //     drive.Media? media;
  //     if (Platform.isAndroid) {
  //       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //       if (androidInfo.isPhysicalDevice == false) {
  //         final Stream<List<int>> mediaStream =
  //             Future.value([105, 106]).asStream().asBroadcastStream();
  //         media = drive.Media(mediaStream, 2);
  //       }
  //     }
  //     media ??= drive.Media(file.openRead(), await file.length());
  //     drive.File result;
  //     if (fileList.files?.isNotEmpty == true &&
  //         fileList.files!.first.id != null) {
  //       result = await driveApi.files
  //           .update(driveFile, fileList.files!.first.id!, uploadMedia: media);
  //     } else {
  //       //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
  //       driveFile.parents = ['appDataFolder'];

  //       result = await driveApi.files.create(driveFile,
  //           uploadMedia: media,
  //           uploadOptions: drive.UploadOptions.defaultOptions);
  //     }
  //     log("Upload result: $result");
  //     return result;
  //   }
  //   return null;
  // }

  // @override
  // Future<String?> download(
  //   File file,
  //   String cloudFileName,
  // ) async {
  //   // await getAccount();
  //   String? cloudVersion;
  //   if (account != null) {
  //     final authHeaders = await account!.authHeaders;
  //     final authenticateClient = GoogleAuthClient(authHeaders);
  //     final driveApi = drive.DriveApi(authenticateClient);
  //     var fileList = await driveApi.files.list(
  //         q: "name='$cloudFileName' and 'appDataFolder' in parents and trashed = false",
  //         spaces: 'appDataFolder',
  //         $fields: 'files(id, version)');

  //     if (fileList.files?.isNotEmpty != true ||
  //         fileList.files!.first.id == null) {
  //       throw FileCloudNotFoundException();
  //     }

  //     var result = await driveApi.files.get(
  //       fileList.files!.first.id!,
  //       downloadOptions: drive.DownloadOptions.fullMedia,
  //       // $fields: 'files(id, version)',
  //     );
  //     drive.Media cloudFile = result as drive.Media;
  //     //  final directory = await getExternalStorageDirectory();
  //     //  print(directory.path);
  //     //  final saveFile = File('${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
  //     try {
  //       List<int> dataStore = [];
  //       await for (final data in cloudFile.stream) {
  //         dataStore.insertAll(dataStore.length, data);
  //       }
  //       log("Task Done");
  //       await file.writeAsBytes(dataStore);
  //       log("File saved at ${file.path}");
  //     } catch (e, st) {
  //       log(e.toString(), stackTrace: st);
  //       rethrow;
  //     }

  //     // cloudFile.stream.listen((data) {
  //     //   print("DataReceived: ${data.length}");
  //     //   dataStore.insertAll(dataStore.length, data);
  //     // }, onDone: () {
  //     //   print("Task Done");
  //     //   file.writeAsBytes(dataStore);
  //     //   if (onDone != null) {
  //     //     onDone(fileList.files!.first.version);
  //     //   }
  //     //   print("File saved at ${file.path}");
  //     // }, onError: (error) {
  //     //   print("Some Error");
  //     // });
  //     cloudVersion = fileList.files!.first.version;
  //   }
  //   return cloudVersion;
  // }

  @override
  Future<List<String?>> upload(String? folderId, String folderName, File file,
      String cloudFileId) async {
    // await getAccount();
    if (account != null) {
      folderId ??= (await getFolder(folderName)).id;
      if (folderId == null) {
        final authHeaders = await account!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = drive.DriveApi(authenticateClient);
        var driveFile = drive.File();
        driveFile.name = basename(file.path);
        // var fileList = await driveApi.files.list(
        //     q: "name='${driveFile.name}' and '${folder.id}' in parents and mimeType != 'application/vnd.google-apps.folder' and trashed = false",
        //     spaces: 'appDataFolder',
        //     $fields: 'files(id)');

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
        drive.File? cloudFileMetadata;
        if (cloudFileId.isNotEmpty) {
          cloudFileMetadata = await driveApi.files
              .get(cloudFileId, $fields: "id") as drive.File;
        }

        if (cloudFileMetadata != null && cloudFileMetadata.id != null) {
          result = await driveApi.files.update(driveFile, cloudFileMetadata.id!,
              uploadMedia: media, $fields: 'id');
        } else {
          //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
          driveFile.parents = [folderId!];
          result = await driveApi.files
              .create(driveFile, uploadMedia: media, $fields: 'id');
        }
        if (result.id != null) {
          result = await driveApi.files.get(result.id!, $fields: "version")
              as drive.File;
        }
        log("Upload result: $result");
        return [result.id, result.version];
      }
    }
    return const [];
  }

  @override
  Future<List> downloadStream(
      String? folderId, String folderName, String cloudFileId) async {
    if (account != null) {
      // folderId ??= (await getFolder(folderName)).id;
      // if (folderId == null) {
      //   return [null, 0, null];
      // }

      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      // var fileList = await driveApi.files.list(
      //     q: "name='$cloudFileName' and '${folder.id}' in parents and mimeType != 'application/vnd.google-apps.folder' and trashed = false",
      //     spaces: 'appDataFolder',
      //     $fields: 'files(id, version)');
      // if (fileList.files?.isNotEmpty != true ||
      //     fileList.files!.first.id == null) {
      //   throw FileCloudNotFoundException();
      // }

      // var result = await driveApi.files.get(
      //   fileList.files!.first.id!,
      //   downloadOptions: drive.DownloadOptions.fullMedia,
      //   // $fields: 'files(id, version)',
      // );

      var cloudFileMetadata = await driveApi.files
          .get(cloudFileId, $fields: "version") as drive.File;
      var result = await driveApi.files.get(
        cloudFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
        // $fields: 'files(id, version)',
      );
      drive.Media cloudFile = result as drive.Media;
      return [
        cloudFile.stream,
        cloudFile.length,
        cloudFileMetadata.version,
      ];
      // var testData = [
      //   100,
      //   100,
      //   100,
      // ];

      // const downloadProgressStops = [0.0, 0.15, 0.45, 0.8, 1.0];
      // Stream<List<int>> mediaStream = () async* {
      //   for (final stop in downloadProgressStops) {
      //     // Wait a second to simulate varying download speeds.
      //     await Future<void>.delayed(const Duration(seconds: 1));
      //     yield testData;
      //   }
      // }();

      // return [mediaStream, downloadProgressStops.length * testData.length, "1"];
    }

    return [null, 0, null];
  }

  @override
  bool isAuth() {
    return googleSignIn.currentUser != null;
  }

  Future<drive.File> getFolder(String folderName) async {
    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    var folderList = await driveApi.files.list(
        q: "name='$folderName' and mimeType = 'application/vnd.google-apps.folder' and 'appDataFolder' in parents and trashed = false",
        spaces: 'appDataFolder',
        $fields: 'files(id)');
    drive.File cloudFolder;
    if (folderList.files?.isNotEmpty != true) {
      var driveFolder = drive.File();
      driveFolder.name = folderName;
      driveFolder.parents = ['appDataFolder'];
      driveFolder.mimeType = 'application/vnd.google-apps.folder';
      cloudFolder = await driveApi.files.create(driveFolder, $fields: 'id');
    } else {
      cloudFolder = folderList.files!.first;
    }
    return cloudFolder;
  }

  @override
  Future<List<String?>> getFileMetadata(
      String? folderId, String folderName, String fileName) async {
    if (account != null) {
      folderId ??= (await getFolder(folderName)).id;
      if (folderId != null) {
        final authHeaders = await account!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = drive.DriveApi(authenticateClient);
        var fileList = await driveApi.files.list(
            q: "name='$fileName' and '$folderId' in parents and mimeType != 'application/vnd.google-apps.folder' and trashed = false",
            spaces: 'appDataFolder',
            $fields: 'files(id, version)');
        if (fileList.files?.isNotEmpty == true) {
          return [fileList.files!.first.id, fileList.files!.first.version];
        }
      }
    }
    return const [];
  }

  @override
  Future<List<Map>?> getChanges(String? folderId, String folderName) async {
    if (account == null) {
      return null;
    }
    final folder = await getFolder(folderName);
    if (folder.id == null) {
      return null;
    }

    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    if (startPageToken == null) {
      drive.StartPageToken response =
          await driveApi.changes.getStartPageToken();
      startPageToken = response.startPageToken;
    }

    if (startPageToken == null) {
      return null;
    }
    drive.ChangeList response = await driveApi.changes.list(
      startPageToken!,
      spaces: 'appDataFolder',
    );

    startPageToken = response.nextPageToken ?? response.newStartPageToken;
    var result = response.changes
        ?.takeWhile(
            (element) => element.file?.parents?.contains(folder.id!) == true)
        .map((element) {
      return {
        "fileId": element.fileId,
        "removed": element.removed,
        "version": element.file?.version,
      };
    }).toList();

    return result;
  }

  @override
  Future<void> init() async {
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      drive.StartPageToken response =
          await driveApi.changes.getStartPageToken();
      startPageToken = response.startPageToken;
    }
  }

  @override
  Future<String?> getFolderId(String folderName) async {
    if (account != null) {
      final folder = await getFolder(folderName);
      return folder.id;
    }
    return null;
  }
}
