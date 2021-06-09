// @dart=2.7
// ^ Do not remove until migrated to null safety. More info at https://wiki.atl.workiva.net/pages/viewpage.action?pageId=189370832
import 'dart:html';

import 'benchmarks.dart' as benchmarks;

main() {
  querySelector('#runButton').onClick.listen((_) {
    benchmarks.main();
  });
}
