import 'dart:html';

import 'benchmarks.dart' as benchmarks;

main() {
  querySelector('#runButton').onClick.listen((_) {
    print('Running benchmark..');
    benchmarks.main();
    print('Benchmarks complete');
  });
}
