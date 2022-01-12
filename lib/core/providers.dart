// Package imports:
import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final cameraProvider = FutureProvider((ref) async {
  final cameras = await availableCameras();
  return cameras[0];
});
