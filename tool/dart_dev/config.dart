import 'package:dart_dev/dart_dev.dart';

final Map<String, DevTool> config = {
  'analyze': AnalyzeTool()..analyzerArgs,
  'format': FormatTool(),
  'test': TestTool(),
};
