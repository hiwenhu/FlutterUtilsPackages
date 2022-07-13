// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter/material.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return HomePage();
//   }
// }

// // class HomePage extends StatefulWidget {
// //   @override
// //   _HomePageState createState() => _HomePageState();
// // }

// // class DecodeParam {
// //   final Uint8List buffer;
// //   final SendPort sendPort;
// //   DecodeParam(this.buffer, this.sendPort);
// // }

// // void decodeIsolate(DecodeParam param) async {
// //   // Read an image from file (webp in this case).
// //   // decodeImage will identify the format of the image and use the appropriate
// //   // decoder.
// //   var image = imagepkg.decodeImage(param.buffer)!;
// //   // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
// //   var thumbnail = imagepkg.copyResize(image, width: 120);
// //   // param.sendPort.send(thumbnail);
// //   param.sendPort.send(image);
// // }

// // // Decode and process an image file in a separate thread (isolate) to avoid
// // // stalling the main UI thread.
// // Future<List<int>> loadImage() async {
// //   var receivePort = ReceivePort();
// //   var buffer = (await rootBundle.load('assets/vango.jpg')).buffer.asUint8List();
// //   await Isolate.spawn(decodeIsolate, DecodeParam(buffer, receivePort.sendPort));

// //   // Get the processed image from the isolate.
// //   var image = await receivePort.first as imagepkg.Image;
// //   return imagepkg.encodePng(image);
// //   //await File('thumbnail.png').writeAsBytes(imagepkg.encodePng(image));
// // }

// // Future<imagepkg.Image> loadImage1() async {
// //   var receivePort = ReceivePort();
// //   var buffer = (await rootBundle.load('assets/vango.jpg')).buffer.asUint8List();
// //   await Isolate.spawn(decodeIsolate, DecodeParam(buffer, receivePort.sendPort));

// //   // Get the processed image from the isolate.
// //   return await receivePort.first as imagepkg.Image;
// // }

// // Stream<List<int>> timerImage() async* {
// //   imagepkg.Image origin = await loadImage1();
// //   // Timer.periodic(Duration(milliseconds: 500), (timer) {
// //   //   origin.setPixelSafe()
// //   // });
// //   int count = 0;
// //   for (var i = 0; i < origin.width; ++i) {
// //     for (var j = 0; j < origin.height; ++j) {
// //       origin.setPixelRgba(i, j, 0, 0, 0);
// //       // ++count;
// //       // if (count == 900) {
// //       //   count = 0;
// //       await Future.delayed(const Duration(milliseconds: 500));
// //       // }
// //       yield imagepkg.encodePng(origin);
// //     }
// //   }
// // }

// // class _HomePageState extends State<HomePage> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       // child: FutureBuilder<List<int>>(
// //       //     future: loadImage(),
// //       //     builder: (context, snapshot) {
// //       //       if (snapshot.hasData) {
// //       //         return Image.memory(Uint8List.fromList(snapshot.data!));
// //       //       }
// //       //       return const CircularProgressIndicator();
// //       //     }),
// //       child: StreamBuilder<List<int>>(
// //           stream: timerImage(),
// //           builder: (context, snapshot) {
// //             if (snapshot.hasData) {
// //               return Image.memory(Uint8List.fromList(snapshot.data!));
// //             }
// //             return const CircularProgressIndicator();
// //           }),
// //     );
// //   }
// // }
import 'package:flutter/material.dart';
import 'testpaint.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}
