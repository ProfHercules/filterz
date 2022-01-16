// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:bitmap/bitmap.dart';
import 'package:camera/camera.dart';
import 'package:dartx/dartx.dart';

// Project imports:
import 'package:filterz/core/core.dart';
import 'package:flutter/material.dart';

abstract class ProcessingStage {
  const ProcessingStage();
  void initialize(int pixelCount);
  void processBytes(Uint8List bytes, int idx);
}

class ProcessPipeline {
  ProcessPipeline(this.stages);
  final List<ProcessingStage> stages;

  Image getImage(CameraImage image) {
    final bytes = image.planes.first.bytes;

    for (final stage in stages) {
      stage.initialize(bytes.length);
    }

    for (var i = 0; i < bytes.length; i += 4) {
      for (final stage in stages) {
        stage.processBytes(bytes, i);
      }
    }

    final bmp = Bitmap.fromHeadless(image.width, image.height, bytes);

    return Image.memory(
      bmp.buildHeaded(),
      gaplessPlayback: true,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
    );
  }
}

class BGRAtoRGBAStage implements ProcessingStage {
  const BGRAtoRGBAStage();

  @override
  void initialize(int pixelCount) {}

  @override
  void processBytes(Uint8List bytes, int idx) {
    final b = bytes[idx + 0];
    final g = bytes[idx + 1];
    final r = bytes[idx + 2];

    bytes[idx + 0] = r;
    bytes[idx + 1] = g;
    bytes[idx + 2] = b;
  }
}

class MotionImageProcessor implements ProcessingStage {
  MotionImageProcessor({this.diffMin = 0});

  final int diffMin;
  Uint8List? _prevBytes;

  @override
  void initialize(int pixelCount) {
    _prevBytes ??= Uint8List(pixelCount);
  }

  @override
  void processBytes(Uint8List bytes, int idx) {
    final r = bytes[idx + 0];
    final g = bytes[idx + 1];
    final b = bytes[idx + 2];

    final pr = _prevBytes![idx + 0];
    final pg = _prevBytes![idx + 1];
    final pb = _prevBytes![idx + 2];

    final diffR = ((r - pr).abs() + diffMin).clamp(0, 255);
    final diffG = ((g - pg).abs() + diffMin).clamp(0, 255);
    final diffB = ((b - pb).abs() + diffMin).clamp(0, 255);

    final maxDiff = [diffR, diffG, diffB].max()! + 1;
    final gain = 1 / maxDiff;

    bytes[idx + 0] = (r * pow(diffR / 255, gain).toDouble()).round();
    bytes[idx + 1] = (g * pow(diffG / 255, gain).toDouble()).round();
    bytes[idx + 2] = (b * pow(diffB / 255, gain).toDouble()).round();

    _prevBytes![idx + 0] = r;
    _prevBytes![idx + 1] = g;
    _prevBytes![idx + 2] = b;
  }
}

class GhostImageProcessor implements ProcessingStage {
  GhostImageProcessor({this.historyLength = 50});

  final int historyLength;

  Uint8List? _prevBytes;

  @override
  void initialize(int pixelCount) {
    _prevBytes ??= Uint8List(pixelCount);
  }

  @override
  void processBytes(Uint8List bytes, int idx) {
    final r = bytes[idx + 0];
    final g = bytes[idx + 1];
    final b = bytes[idx + 2];

    final pr = _prevBytes![idx + 0];
    final pg = _prevBytes![idx + 1];
    final pb = _prevBytes![idx + 2];

    if (historyLength <= 0) {
      bytes[idx + 0] = r;
      bytes[idx + 1] = g;
      bytes[idx + 2] = b;
      return;
    }

    final diffR = (r + pr * historyLength).floorDivide(historyLength + 1);
    final diffG = (g + pg * historyLength).floorDivide(historyLength + 1);
    final diffB = (b + pb * historyLength).floorDivide(historyLength + 1);

    bytes[idx + 0] = diffR;
    bytes[idx + 1] = diffG;
    bytes[idx + 2] = diffB;

    _prevBytes![idx + 0] = diffR;
    _prevBytes![idx + 1] = diffG;
    _prevBytes![idx + 2] = diffB;
  }
}

class ColorCompressProcessor implements ProcessingStage {
  const ColorCompressProcessor({this.colors = 3});

  final int colors;

  @override
  void initialize(int pixelCount) {}

  @override
  void processBytes(Uint8List bytes, int idx) {
    final r = bytes[idx + 0];
    final g = bytes[idx + 1];
    final b = bytes[idx + 2];

    final groupSize = 255.floorDivide(colors);

    bytes[idx + 0] = (r.ceilDivide(groupSize) * groupSize).clamp(0, 255);
    bytes[idx + 1] = (g.ceilDivide(groupSize) * groupSize).clamp(0, 255);
    bytes[idx + 2] = (b.ceilDivide(groupSize) * groupSize).clamp(0, 255);
  }
}
