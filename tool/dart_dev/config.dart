import 'package:dart_dev/dart_dev.dart';
import 'package:dart_dev_workiva/dart_dev_workiva.dart';

final config = {
  ...workivaConfig,
  'serve': WebdevServeTool()..buildArgs = ['example'],
}
