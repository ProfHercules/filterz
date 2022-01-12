import 'package:bitmap/bitmap.dart';
import 'package:camera/camera.dart';
import 'package:filterz/core/core.dart';

ProcessResult processImage(CameraImage image) {
  var avgR = 0;
  var avgG = 0;
  var avgB = 0;
  const avgA = 255;

  // BGRA format
  final bytes = image.planes.first.bytes;
  final pixelCount = bytes.length * 0.25;

  // -> RGBA|BGRA
  // -> RGBA format
  for (var i = 0; i < bytes.length; i += 4) {
    final b = bytes[i];
    final g = bytes[i + 1];
    final r = bytes[i + 2];

    bytes[i] = r;
    bytes[i + 1] = g;
    bytes[i + 2] = b;

    avgR += r;
    avgG += g;
    avgB += b;
  }

  final bmp = Bitmap.fromHeadless(image.width, image.height, bytes);

  return ProcessResult(
    bmp: bmp,
    avgR: avgR.floorDivide(pixelCount),
    avgG: avgG.floorDivide(pixelCount),
    avgB: avgB.floorDivide(pixelCount),
    avgA: avgA,
  );
}
