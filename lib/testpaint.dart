import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imagepkg;
import 'dart:ui' as ui;

//通过[Uint8List]获取图片
Future<ui.Image> loadImageByUint8List(Uint8List list) async {
  ui.Codec codec = await ui.instantiateImageCodec(list);
  ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

//通过 文件读取Image
Future<List> loadImageByFile(String path) async {
  var list = (await rootBundle.load(path)).buffer.asUint8List();
  var imagePkgImg = imagepkg.decodeImage(list)!;
  list = Uint8List.fromList(
      imagepkg.encodePng(imagepkg.copyRotate(imagePkgImg, 90)));
  var origin = await loadImageByUint8List(list);
  var grayscale = await loadImageByUint8List(
      // Uint8List.fromList(imagepkg.encodePng(imagePkgImg)));
      Uint8List.fromList(imagepkg.encodePng(imagepkg.grayscale(imagePkgImg))));
  return [origin, grayscale, imagePkgImg];
}

class ShapePainter extends CustomPainter {
  final Animation<double> factor;
  final ui.Image image;
  final ui.Image grayScaleImage;
  final imagepkg.Image imagePkgImg;
  double percent = 0;
  Map<Color, List<Offset>> colorPoints = {};
  ShapePainter(
      {required this.factor,
      required this.image,
      required this.grayScaleImage,
      required this.imagePkgImg})
      : super(repaint: factor) {
    for (int w = 0; w < imagePkgImg.width; ++w) {
      for (int h = 0; h < imagePkgImg.height; ++h) {
        int color = imagePkgImg.getPixel(w, h);
        //#AABBGGRR
        color = color & 0xFF000000 |
            ((color & 0x000000FF) << 16) |
            (color & 0x0000FF00) |
            ((color & 0x00FF0000) >> 16);
        //#AARRGGBB
        Color c = Color(color);
        var points = colorPoints[c];
        var point = Offset(w.toDouble() / imagePkgImg.width,
            h.toDouble() / imagePkgImg.height);
        if (points == null) {
          colorPoints[c] = [point];
        } else {
          points.add(point);
        }
      }
    }
  }
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      // ..color = Color.lerp(Colors.red, Colors.blue, factor.value)!
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
    // canvas.drawCircle(
    //     Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    int colorCount = (image.width * image.height * factor.value).toInt();
    int imageHeight = image.height;
    int imageWidth = image.width;
    int colorHeight = (colorCount / imageWidth).ceil();
    int colorWidth = colorCount % imageWidth;
    double canvasHeight = colorHeight / imageHeight * size.height;
    double canvasWidth = colorWidth / imageWidth * size.width;

    if (colorHeight > 0) {
      Path path = Path();
      path.moveTo(0, 0);
      path.lineTo(0, canvasHeight);
      path.lineTo(size.width, canvasHeight);
      path.lineTo(size.width, 0);
      if (factor.value == 1) {
        path.close();
      }
      canvas.drawPath(path, paint);
      // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, canvasHeight), paint);
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, imageHeight.toDouble() - colorHeight.toDouble(),
              imageWidth.toDouble(), colorHeight.toDouble()),
          Rect.fromLTWH(0, 0, size.width, canvasHeight),
          paint);
    }

    // canvas.drawImageRect(
    //     image,
    //     Rect.fromLTWH(0, colorHeight.toDouble(), colorWidth.toDouble(), 1),
    //     Rect.fromLTRB(0, canvasHeight, canvasWidth, canvasHeight + 1),
    //     paint);

    // paint.color = Colors.black;
    // canvas.drawLine(Offset(canvasWidth, canvasHeight - 20),
    //     Offset(canvasWidth, canvasHeight), paint);

    // canvas.drawImageRect(
    //     grayScaleImage,
    //     Rect.fromLTRB(colorWidth.toDouble(), colorHeight.toDouble(),
    //         image.width.toDouble(), colorHeight.toDouble()),
    //     Rect.fromLTRB(colorWidth / image.width * size.width, canvasHeight,
    //         size.width, canvasHeight + 1),
    //     paint);

    // canvas.drawImageRect(
    //     grayScaleImage,
    //     Rect.fromLTRB(0, (colorHeight + 1).toDouble(), image.width.toDouble(),
    //         image.height.toDouble()),
    //     Rect.fromLTRB(0, (colorHeight + 1) / image.height * size.height,
    //         size.width, size.height),
    //     paint);

    // canvas.drawImageRect(
    //     grayScaleImage,
    //     Rect.fromLTWH(
    //         0, 0, factor.value * image.width, factor.value * image.height),
    //     Rect.fromLTWH(
    //         0, 0, factor.value * size.width, factor.value * size.height),
    //     paint);

    // var cnt = (colorPoints.length * factor.value).toInt();
    // for (int i = 0; i < cnt; ++i) {
    //   // paint.color = colorPoints.keys.elementAt(i);
    //   var color = colorPoints.keys.elementAt(i);
    //   var points = colorPoints[color];

    //   if (points == null) continue;
    //   paint.color = color;
    //   points = points
    //       .map((e) => Offset(e.dx * size.width, e.dy * size.height))
    //       .toList()
    //       .sublist(0, min(1000, points.length));
    //   canvas.drawPoints(ui.PointMode.points, points, paint);
    // }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.factor != factor;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Future<List> imageFutre;
  int duration = 10;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: Duration(seconds: duration));
    _ctrl.forward();
    imageFutre = loadImageByFile('assets/vango.jpg');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String getLeftTime() {
    var left = (duration - duration * _ctrl.value).ceil();
    int h = (left / 3600).floor();
    left = left - h * 3600;
    int m = (left / 60).floor();
    left = left - m * 60;
    int s = left;
    return '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              // _ctrl.reset();
              _ctrl.forward(from: 0);
            },
            child: const Text('reset'),
          ),
        ],
      ),
      body: FutureBuilder<List>(
        future: imageFutre,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            var image = snapshot.data![0];
            return Stack(
              fit: StackFit.passthrough,
              children: [
                const Positioned(
                  left: 12,
                  right: 12,
                  child: SizedBox(
                    width: 300,
                    height: 600,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image(image: AssetImage("assets/printer.png")),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, __) => Text(
                        getLeftTime(),
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 330,
                  left: 60,
                  child: Center(
                    child: SizedBox(
                      width: 240,
                      height: 360,
                      //<--- 使用绘制组件
                      child: CustomPaint(
                        // size: Size(100, 100),
                        painter: ShapePainter(
                            factor: _ctrl,
                            image: snapshot.data![0],
                            grayScaleImage: snapshot.data![1],
                            imagePkgImg: snapshot.data![2]), //<--- 设置画板
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
