// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:filterz/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: App()));
}
