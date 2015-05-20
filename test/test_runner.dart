import './r_tree/r_tree_test.dart' as r_tree_test;
import './r_tree/leaf_node_test.dart' as leaf_node_test;
import './r_tree/non_leaf_node_test.dart' as non_leaf_node_test;
import './r_tree/node_test.dart' as node_test;

import 'package:unittest/vm_config.dart';

void main() {
  useVMConfiguration();
  r_tree_test.main();
  leaf_node_test.main();
  non_leaf_node_test.main();
  node_test.main();
}
