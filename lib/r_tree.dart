/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/// A recursive RTree library written in Dart.
///
/// This R-tree implementation is used to two and query two-dimensional data.
/// Items are inserted and balanced via the RTree class and can then be queried
/// by Rectangle.  The balancing can be tweaked by modifying the branch factor
/// of the RTree.
///
/// "R-trees are tree data structures used for spatial access methods, i.e., for
/// indexing multi-dimensional information such as geographical coordinates,
/// rectangles or polygons." - http://en.wikipedia.org/wiki/R-tree
library r_tree;

import 'dart:math';
import 'package:dart2_constant/core.dart' as core_constant;

part 'src/r_tree/leaf_node.dart';
part 'src/r_tree/non_leaf_node.dart';
part 'src/r_tree/node.dart';
part 'src/r_tree/r_tree.dart';
part 'src/r_tree/r_tree_datum.dart';
part 'src/r_tree/r_tree_contributor.dart';
