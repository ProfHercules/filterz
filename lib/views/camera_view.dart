import 'package:camera/camera.dart';
import 'package:filterz/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

class CameraView extends HookConsumerWidget {
  const CameraView({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useCameraController(camera: camera);
    final cameraStream = useStreamController<ProcessResult>();

    useEffect(() {
      controller.initialize().then(
            (_) => controller.startImageStream(
              (image) => cameraStream.add(processImage(image)),
            ),
          );
    });

    return StreamBuilder<ProcessResult>(
      stream: cameraStream.stream.throttleTime(
        Duration(milliseconds: 1000.floorDivide(fps)),
        leading: false,
        trailing: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final pr = snapshot.data!;
          return SizedBox.expand(
            child: Container(color: pr.avgColor, child: pr.image),
          );
        }

        return MaterialApp(
          home: CameraPreview(controller),
        );
      },
    );
  }
}
