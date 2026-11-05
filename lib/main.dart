import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_providers.dart';
import 'app/life_os_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProviderContainer container = ProviderContainer();
  await container.read(settingsRepositoryProvider).ensureDefaults();
  runApp(
    UncontrolledProviderScope(container: container, child: const LifeOsApp()),
  );
}
