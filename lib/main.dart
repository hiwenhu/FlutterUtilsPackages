import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';

import 'app/app_bloc_observer.dart';
import 'app/view/app.dart';
import 'google_auth_client.dart';

Future<void> main() {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // await Firebase.initializeApp();
      final authenticationRepository = AuthenticationRepository();
      await authenticationRepository.loginWithGoogleSliently();
      var cloudSwitch = await CloudSwitchCubit.getSwitch();
      final fileCloudReposity = GoogleDriveFileRepository(
          authenticationRepository.googleSignIn,
          cloudSwitch == CloudSwitchStatus.on);
      // await authenticationRepository.user.first;
      runApp(App(
        authenticationRepository: authenticationRepository,
        fileCloudReposity: fileCloudReposity,
        cloudSwitchStatus: cloudSwitch,
      ));
    },
    blocObserver: AppBlocObserver(),
  );
}
