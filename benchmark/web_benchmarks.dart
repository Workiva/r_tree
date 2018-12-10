import 'dart:html';

import 'benchmarks.dart' as benchmarks;

main() {
  querySelector('#runButton').onClick.listen((_) {
    print('Re-running');
    benchmarks.main();
  });
}
