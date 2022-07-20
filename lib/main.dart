import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';

import 'app/view/app.dart';
import 'google_auth_client.dart';

Future<void> main() {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // await Firebase.initializeApp();
      final authenticationRepository = AuthenticationRepository();
      await authenticationRepository.loginWithGoogleSliently();
      // await authenticationRepository.user.first;
      runApp(App(
        authenticationRepository: authenticationRepository,
        cloudSwitchStatus: await CloudSwitchCubit.getSwitch(),
      ));
    },
    // blocObserver: AppBlocObserver(),
  );
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final originalTheme = Theme.of(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Theme(
          data: originalTheme.copyWith(
            textTheme: originalTheme.textTheme.copyWith(
              bodyText2: originalTheme.textTheme.bodyText2!.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          child: const MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: const <Widget>[
          TestGoogleDriveApi(),
        ],
      ),
    );
  }
}

//https://betterprogramming.pub/the-minimum-guide-for-using-google-drive-api-with-flutter-9207e4cb05ba
class TestGoogleDriveApi extends StatefulWidget {
  const TestGoogleDriveApi({Key? key}) : super(key: key);

  @override
  State<TestGoogleDriveApi> createState() => _TestGoogleDriveApiState();
}

class _TestGoogleDriveApiState extends State<TestGoogleDriveApi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final googleSignIn = signIn.GoogleSignIn.standard(
                              scopes: [drive.DriveApi.driveAppdataScope]);
                          final signIn.GoogleSignInAccount? account =
                              await googleSignIn.signIn();
                          print("User account $account");
                          if (account != null) {
                            final authHeaders = await account.authHeaders;
                            final authenticateClient =
                                GoogleAuthClient(authHeaders);
                            final driveApi = drive.DriveApi(authenticateClient);
                            final Stream<List<int>> mediaStream =
                                Future.value([105, 106, 110])
                                    .asStream()
                                    .asBroadcastStream();
                            var media = drive.Media(mediaStream, 3);
                            // String? id;
                            // var isqlFolder = await driveApi.files.list(
                            //     q: "name='isql' and mimeType='application/vnd.google-apps.folder' and trashed = false");
                            // if (isqlFolder.files?.isNotEmpty == true) {
                            //   id = isqlFolder.files?.first.id;
                            // }
                            // if (id == null) {
                            //   var driveFolder = drive.File();
                            //   driveFolder.name = 'isql';
                            //   driveFolder.mimeType =
                            //       "application/vnd.google-apps.folder";
                            //   var folder =
                            //       await driveApi.files.create(driveFolder);

                            //   id = folder.id;
                            // }

                            // if (id != null) {
                            var driveFile = drive.File();
                            driveFile.name = "testfile1.txt";
                            var fileList = await driveApi.files.list(
                                q: "name='${driveFile.name}' and 'appDataFolder' in parents and trashed = false",
                                spaces: 'appDataFolder',
                                $fields: 'files(id)');
                            drive.File result;
                            if (fileList.files?.isNotEmpty == true &&
                                fileList.files!.first.id != null) {
                              result = await driveApi.files.update(
                                  driveFile, fileList.files!.first.id!,
                                  uploadMedia: media);
                            } else {
                              driveFile.parents = [
                                'appDataFolder'
                              ]; //新建文件时才能用这句，否则会报错，移动文件到其他目录使用update方法中的参数addParents removeParents
                              result = await driveApi.files
                                  .create(driveFile, uploadMedia: media);
                            }
                            print("Upload result: $result");
                            // } else {
                            //   print('Folder not exists');
                            // }

                            //   var pickRes = await FilePicker.platform.pickFiles();

                            //   if (pickRes != null && pickRes.files.isNotEmpty) {
                            //     if (pickRes.files.first.readStream != null) {
                            //       var media = drive.Media(
                            //           pickRes.files.first.readStream!, 2);
                            //       var driveFile = drive.File();
                            //       driveFile.name =
                            //           "isql/${pickRes.files.first.name}";
                            //       final result = await driveApi.files
                            //           .create(driveFile, uploadMedia: media);
                            //       print("Upload result: $result");
                            //     }
                            //   }
                            // File testFile = File('tmp.txt');
                            // if (!(await testFile.exists())) {
                            //   await testFile.writeAsString(
                            //       'lalsdfaT@#4GFASDasdas岁的法国#T双方的');
                            //   var media = drive.Media(testFile.openRead(), 2);
                            //   var driveFile = drive.File();
                            //   driveFile.name = "isql/testReadFile.txt";
                            //   final result = await driveApi.files
                            //       .create(driveFile, uploadMedia: media);
                            //   print("Upload result: $result");
                            // }
                          }
                        } catch (e, ex) {
                          print('error $e $ex');
                        }
                      },
                      child: const Text('Use Drive'),
                    ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                    // TextFormField(
                    //   decoration:
                    //       const InputDecoration(border: OutlineInputBorder()),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ));
    // return Stack(
    //   children: [
    //     Positioned(
    //       bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    //       left: 0,
    //       right: 0,
    //       child: const TextFormField(
    //         decoration: InputDecoration(border: OutlineInputBorder()),
    //       ),
    //     )
    //   ],
    // );
  }
}

class FullStack extends StatefulWidget {
  const FullStack({Key? key}) : super(key: key);

  @override
  State<FullStack> createState() => _FullStackState();
}

class _FullStackState extends State<FullStack> {
  bool _safeArea = true;
  bool _fakeKeyboard = false;

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Uncomment this if you want to summon the real keyboard on mobile.
        // const SizedBox(height: 100),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   child: Row(
        //     children: <Widget>[
        //       Expanded(
        //         child: TextFormField(
        //           decoration: InputDecoration(
        //             filled: true,
        //             fillColor: Colors.grey[300],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Flexible(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final keyboardTextStyle = Theme.of(context).textTheme.headline2;
              late final EdgeInsets viewPadding;
              late final EdgeInsets padding;

              late final EdgeInsets positioning;

              if (!_safeArea && !_fakeKeyboard) {
                viewPadding = const EdgeInsets.symmetric(vertical: 20);
                padding = const EdgeInsets.symmetric(vertical: 20);
                positioning = EdgeInsets.zero;
              } else if (_safeArea && !_fakeKeyboard) {
                viewPadding = EdgeInsets.zero;
                padding = EdgeInsets.zero;
                positioning = const EdgeInsets.symmetric(vertical: 20);
              } else if (!_safeArea && _fakeKeyboard) {
                viewPadding = const EdgeInsets.symmetric(vertical: 20);
                padding = const EdgeInsets.fromLTRB(0, 20, 0, 0);
                positioning = EdgeInsets.zero;
              } else {
                // Have both
                viewPadding = const EdgeInsets.fromLTRB(0, 0, 0, 20);
                padding = EdgeInsets.zero;
                positioning = const EdgeInsets.only(top: 20);
              }

              final MediaQueryData mq = MediaQuery.of(context).copyWith(
                padding: padding,
                viewPadding: viewPadding,
                viewInsets: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  _fakeKeyboard ? 300 : 0,
                ),
              );
              return Stack(
                children: <Widget>[
                  // Top notch (heh)
                  Positioned(
                    left: mq.size.width / 4,
                    top: 10,
                    child: Container(
                      height: 5,
                      width: mq.size.width / 2,
                      color: Colors.grey[800],
                    ),
                  ),
                  // Bottom notch
                  !_fakeKeyboard
                      ? Positioned(
                          left: mq.size.width / 4,
                          bottom: 10,
                          child: Container(
                            height: 5,
                            width: mq.size.width / 2,
                            color: Colors.grey[800],
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: mq.size.height / 2,
                    left: mq.size.width / 2.5,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Fake keyboard is ${_fakeKeyboard ? "REVEALED" : "HIDDEN"}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Switch(
                          value: _fakeKeyboard,
                          onChanged: (value) {
                            setState(() {
                              _fakeKeyboard = value;
                            });
                          },
                        ),
                        Text(
                          'SafeArea is ${_safeArea ? "ON" : "OFF"}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Switch(
                          value: _safeArea,
                          onChanged: (value) {
                            setState(() {
                              _safeArea = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: positioning.top,
                    left: mq.size.width / 2.2,
                    child: MediaQueryTopInfo(mediaQueryData: mq),
                  ),
                  Positioned(
                    top: mq.size.height / 2.5 - mq.viewInsets.bottom / 2,
                    left: positioning.left,
                    child: MediaQueryLeftInfo(mediaQueryData: mq),
                  ),
                  Positioned(
                    top: mq.size.height / 2.5 - mq.viewInsets.bottom / 2,
                    right: positioning.right,
                    child: MediaQueryRightInfo(mediaQueryData: mq),
                  ),
                  Positioned(
                    bottom: positioning.bottom + mq.viewInsets.bottom,
                    left: mq.size.width / 2.2,
                    child: MediaQueryBottomInfo(mediaQueryData: mq),
                  ),
                  _fakeKeyboard
                      ? Positioned(
                          bottom: 0,
                          width: mq.size.width,
                          height: 300,
                          child: Container(
                            color: Colors.grey[300],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text('K', style: keyboardTextStyle),
                                Text('E', style: keyboardTextStyle),
                                Text('Y', style: keyboardTextStyle),
                                Text('B', style: keyboardTextStyle),
                                Text('O', style: keyboardTextStyle),
                                Text('A', style: keyboardTextStyle),
                                Text('R', style: keyboardTextStyle),
                                Text('D', style: keyboardTextStyle),
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class MediaQueryBottomInfo extends StatelessWidget {
  const MediaQueryBottomInfo({Key? key, required this.mediaQueryData})
      : super(key: key);

  final MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    final viewInsets = mediaQueryData.viewInsets;
    final viewPadding = mediaQueryData.viewPadding;
    final padding = mediaQueryData.padding;
    return Column(
      children: <Widget>[
        const Text('BOTTOM'),
        Text('Padding: ${padding.bottom}'),
        Text('ViewPadding: ${viewPadding.bottom}'),
        Text('ViewInsets: ${viewInsets.bottom}'),
      ],
    );
  }
}

class MediaQueryTopInfo extends StatelessWidget {
  const MediaQueryTopInfo({Key? key, required this.mediaQueryData})
      : super(key: key);

  final MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    final viewInsets = mediaQueryData.viewInsets;
    final viewPadding = mediaQueryData.viewPadding;
    final padding = mediaQueryData.padding;
    return Column(
      children: <Widget>[
        const Text('TOP'),
        Text('Padding: ${padding.top}'),
        Text('ViewPadding: ${viewPadding.top}'),
        Text('ViewInsets: ${viewInsets.top}'),
      ],
    );
  }
}

class MediaQueryLeftInfo extends StatelessWidget {
  const MediaQueryLeftInfo({Key? key, required this.mediaQueryData})
      : super(key: key);

  final MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    final viewInsets = mediaQueryData.viewInsets;
    final viewPadding = mediaQueryData.viewPadding;
    final padding = mediaQueryData.padding;
    return Column(
      children: <Widget>[
        const Text('LEFT'),
        Text('Padding: ${padding.left}'),
        Text('ViewPadding: ${viewPadding.left}'),
        Text('ViewInsets: ${viewInsets.left}'),
      ],
    );
  }
}

class MediaQueryRightInfo extends StatelessWidget {
  const MediaQueryRightInfo({Key? key, required this.mediaQueryData})
      : super(key: key);

  final MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    final viewInsets = mediaQueryData.viewInsets;
    final viewPadding = mediaQueryData.viewPadding;
    final padding = mediaQueryData.padding;
    return Column(
      children: <Widget>[
        const Text('RIGHT'),
        Text('Padding: ${padding.right}'),
        Text('ViewPadding: ${viewPadding.right}'),
        Text('ViewInsets: ${viewInsets.right}'),
      ],
    );
  }
}
