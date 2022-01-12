import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates and disposes a [CameraController].
CameraController useCameraController({
  required CameraDescription camera,
  ResolutionPreset resolutionPreset = ResolutionPreset.low,
  bool enableAudio = false,
  ImageFormatGroup imageFormatGroup = ImageFormatGroup.bgra8888,
  List<Object?>? keys,
}) =>
    use(
      _CameraControllerHook(
        camera: camera,
        resolutionPreset: resolutionPreset,
        enableAudio: enableAudio,
        imageFormatGroup: imageFormatGroup,
      ),
    );

class _CameraControllerHook extends Hook<CameraController> {
  const _CameraControllerHook({
    required this.camera,
    required this.resolutionPreset,
    required this.enableAudio,
    this.imageFormatGroup,
    List<Object?>? keys,
  }) : super(keys: keys);

  final CameraDescription camera;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final ImageFormatGroup? imageFormatGroup;

  @override
  HookState<CameraController, Hook<CameraController>> createState() =>
      _CameraControllerHookState();
}

class _CameraControllerHookState
    extends HookState<CameraController, _CameraControllerHook> {
  @override
  void initHook() {
    super.initHook();
    // controller.initialize();
  }

  late final controller = CameraController(
    hook.camera,
    hook.resolutionPreset,
    enableAudio: hook.enableAudio,
    imageFormatGroup: hook.imageFormatGroup,
  );

  @override
  CameraController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useCameraController';
}
