import 'package:cloud_api/cloud_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import 'google_auth_client.dart';

class GoogleDriveCloudApi extends CloudApi {
  GoogleDriveCloudApi({this.account});
  GoogleSignInAccount? account;

  Future<GoogleSignInAccount?> getAccount() async {
    if (account == null) {
      final googleSignIn =
          GoogleSignIn.standard(scopes: [DriveApi.driveAppdataScope]);
      account = await googleSignIn.signIn();
    }
    return account;
  }

  @override
  Future<void> deleteFile(String fileName) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<List?> listFile() async {
    await getAccount();
    if (account != null) {
      final authHeaders = await account!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = DriveApi(authenticateClient);

      var fileList = await driveApi.files.list(
          q: "'appDataFolder' in parents and trashed = false",
          spaces: 'appDataFolder',
          $fields: 'files(id)');

      return fileList.files;
    }
    return null;
  }

  @override
  Future<void> saveFile(Stream stream) {
    // TODO: implement saveFile
    throw UnimplementedError();
  }
}
