import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'googledrive_cloud_api.dart';

class GoogleDriveFileRepository
    extends FileCloudRepository<GoogleDriveCloudApi> {
  GoogleDriveFileRepository({GoogleSignInAccount? account})
      : super(cloudApi: GoogleDriveCloudApi(account: account));
}
