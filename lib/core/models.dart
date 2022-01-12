import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';

class ProcessResult {
  const ProcessResult({
    required this.bmp,
    required this.avgR,
    required this.avgG,
    required this.avgB,
    required this.avgA,
  });

  final Bitmap bmp;
  final int avgR;
  final int avgG;
  final int avgB;
  final int avgA;

  Image get image => Image.memory(
        bmp.buildHeaded(),
        gaplessPlayback: true,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );

  Color get avgColor => Color.fromARGB(avgA, avgR, avgG, avgB);
}
