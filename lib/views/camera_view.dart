// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:camera/camera.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:filterz/core/core.dart';

class CameraView extends HookConsumerWidget {
  const CameraView({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useCameraController(camera: camera);
    final cameraStream = useStreamController<Image>();

    final ghostHistory = useState<int>(50);

    useEffect(
      () {
        print('Running hook');
        final pipeline = ProcessPipeline([
          const BGRAtoRGBAStage(),
          MotionImageProcessor(),
          GhostImageProcessor(historyLength: ghostHistory.value),
        ]);
        if (controller.value.isInitialized) {
          if (controller.value.isStreamingImages) {
            controller.stopImageStream().then(
                  (_) => controller.startImageStream(
                    (image) => cameraStream.add(pipeline.getImage(image)),
                  ),
                );
            return;
          }
        }
        controller.initialize().then(
          (_) async {
            if (controller.value.isStreamingImages) {
              await controller.stopImageStream();
            }
            return controller.startImageStream(
              (image) => cameraStream.add(pipeline.getImage(image)),
            );
          },
        );
      },
      [ghostHistory.value],
    );

    return Column(
      children: [
        StreamBuilder<Image>(
          stream: cameraStream.stream.throttleTime(
            Duration(milliseconds: 1000.floorDivide(fps)),
            leading: false,
            trailing: true,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: double.infinity,
                color: Colors.grey.shade900,
                child: snapshot.data,
              );
            }

            return const SizedBox.shrink();
          },
        ),
        Slider(
          value: ghostHistory.value.toDouble(),
          onChanged: (val) => ghostHistory.value = val.round(),
          max: 50,
        ),
        Text('Ghosting: ${ghostHistory.value}'),
      ],
    );
  }
}
