import 'dart:async';
import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';

import 'app/app_bloc_observer.dart';
import 'app/view/app.dart';
import 'firebase_options.dart';
import 'google_auth_client.dart';

Future<Directory> getLocalFileRoot() async {
  var directory = await getApplicationSupportDirectory();
  var rootDirName = 'tmp';
  // if (exists) {
  var root = Directory('${directory.path}/$rootDirName');
  if (!await root.exists()) {
    root = await root.create();
  }
  return root;
}

Future<void> main() {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // await Firebase.initializeApp();
      final authenticationRepository = AuthenticationRepository();
      await authenticationRepository.loginWithGoogleSliently();
      var cloudSwitch = await CloudSwitchCubit.getSwitch();
      final fileCloudReposity = GoogleDriveFileRepository(
          await getLocalFileRoot(),
          authenticationRepository.googleSignIn,
          cloudSwitch == CloudSwitchStatus.on);
      // await authenticationRepository.user.first;
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      runZonedGuarded(
          () => runApp(
                App(
                  authenticationRepository: authenticationRepository,
                  fileCloudReposity: fileCloudReposity,
                  cloudSwitchStatus: cloudSwitch,
                ),
              ), (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      });
    },
    blocObserver: AppBlocObserver(),
  );
}
