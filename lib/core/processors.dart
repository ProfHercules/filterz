// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:bitmap/bitmap.dart';
import 'package:camera/camera.dart';
import 'package:dartx/dartx.dart';

// Project imports:
import 'package:filterz/core/core.dart';

abstract class CameraImageProcessor {
  ProcessResult processImage(CameraImage image);
}

class MotionImageProcessor implements CameraImageProcessor {
  Uint8List? _prevBytes;

  @override
  ProcessResult processImage(CameraImage image) {
    var avgR = 0;
    var avgG = 0;
    var avgB = 0;
    const avgA = 255;

    // BGRA format
    final bytes = image.planes.first.bytes;
    _prevBytes ??= Uint8List(bytes.length);

    final pixelCount = bytes.length * 0.25;

    for (var i = 0; i < bytes.length; i += 4) {
      final b = bytes[i + 0];
      final g = bytes[i + 1];
      final r = bytes[i + 2];

      final pr = _prevBytes![i + 0];
      final pg = _prevBytes![i + 1];
      final pb = _prevBytes![i + 2];

      final diffR = (r - pr).abs();
      final diffG = (g - pg).abs();
      final diffB = (b - pb).abs();

      final maxDiff = [diffR, diffG, diffB].max()! + 1;
      final gain = 1 / maxDiff;

      bytes[i + 0] = (r * pow(diffR / 255, gain).toDouble()).round();
      bytes[i + 1] = (g * pow(diffG / 255, gain).toDouble()).round();
      bytes[i + 2] = (b * pow(diffB / 255, gain).toDouble()).round();

      avgR += r;
      avgG += g;
      avgB += b;

      _prevBytes![i + 0] = r;
      _prevBytes![i + 1] = g;
      _prevBytes![i + 2] = b;
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
}

class GhostImageProcessor implements CameraImageProcessor {
  Uint8List? _prevBytes;

  @override
  ProcessResult processImage(CameraImage image) {
    var avgR = 0;
    var avgG = 0;
    var avgB = 0;
    const avgA = 255;

    // BGRA format
    final bytes = image.planes.first.bytes;
    _prevBytes ??= Uint8List(bytes.length);

    final pixelCount = bytes.length * 0.25;

    for (var i = 0; i < bytes.length; i += 4) {
      final b = bytes[i + 0];
      final g = bytes[i + 1];
      final r = bytes[i + 2];

      final pr = _prevBytes![i + 0];
      final pg = _prevBytes![i + 1];
      final pb = _prevBytes![i + 2];

      final diffR = (r + pr * 49).floorDivide(50);
      final diffG = (g + pg * 49).floorDivide(50);
      final diffB = (b + pb * 49).floorDivide(50);

      // final maxDiff = [diffR, diffG, diffB].max()! + 1;
      // final gain = 1 / maxDiff;

      bytes[i + 0] = diffR; //(r * pow(diffR / 255, gain).toDouble()).round();
      bytes[i + 1] = diffG; //(g * pow(diffG / 255, gain).toDouble()).round();
      bytes[i + 2] = diffB; //(b * pow(diffB / 255, gain).toDouble()).round();

      avgR += r;
      avgG += g;
      avgB += b;

      _prevBytes![i + 0] = diffR;
      _prevBytes![i + 1] = diffG;
      _prevBytes![i + 2] = diffB;
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
}
