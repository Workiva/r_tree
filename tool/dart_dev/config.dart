import 'package:dart_dev/dart_dev.dart';

final Map<String, DevTool> config = {
  ...coreConfig,
  'serve': WebdevServeTool()..buildArgs = ['example'],
};
