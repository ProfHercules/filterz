// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:filterz/core/core.dart';
import 'package:filterz/views/views.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider);

    return Scaffold(
      body: camera.when(
        data: (c) => CameraView(camera: c),
        error: (_, __) => throw UnimplementedError(),
        loading: LoadingView.new,
      ),
    );
  }
}
