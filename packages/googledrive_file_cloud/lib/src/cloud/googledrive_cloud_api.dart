import 'package:cloud_api/cloud_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'google_auth_client.dart';

class GoogleDriveCloudApi extends CloudApi {
  GoogleDriveCloudApi({this.account});
  GoogleSignInAccount? account;

  Future<GoogleSignInAccount?> getAccount() async {
    if (account == null) {
      final googleSignIn =
          GoogleSignIn.standard(scopes: [drive.DriveApi.driveAppdataScope]);
      account = await googleSignIn.signIn();
    }
    return account;
  }

  @override
  Future deleteFile(String fileName) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<List<File>> listFile() async {
    await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      var fileList = await driveApi.files.list(
          q: "'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');

      var directory = await getApplicationSupportDirectory();

      return fileList.files
              ?.map((e) => File('${directory.path}/${e.name}'))
              .toList() ??
          [];
    }
    return [];
  }

  @override
  Future<drive.File?> saveFile(File file) async {
    await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      var driveFile = drive.File();
      driveFile.name = file.path;
      var fileList = await driveApi.files.list(
          q: "name='${driveFile.name}' and 'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');
      var media = drive.Media(file.openRead(), file.lengthSync());
      drive.File result;
      if (fileList.files?.isNotEmpty == true &&
          fileList.files!.first.id != null) {
        result = await driveApi.files
            .update(driveFile, fileList.files!.first.id!, uploadMedia: media);
      } else {
        driveFile.parents = [
          'appDataFolder'
        ]; //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
        result = await driveApi.files.create(driveFile, uploadMedia: media);
      }
      print("Upload result: $result");
      return result;
    }
    return null;
  }
}
