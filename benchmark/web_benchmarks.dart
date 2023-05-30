import 'dart:html';

import 'benchmarks.dart' as benchmarks;

main() {
  querySelector('#runButton')!.onClick.listen((_) {
    benchmarks.main();
  });
}
