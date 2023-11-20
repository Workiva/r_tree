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

import 'dart:math';

import 'package:r_tree/src/r_tree/node.dart';
import 'package:r_tree/src/r_tree/r_tree_datum.dart';
import 'package:r_tree/src/r_tree/rectangle_helper.dart';

/// A [Node] that is a leaf node of the tree.  These are created automatically
/// when inserting/removing items from the tree.
class LeafNode<E> extends Node<E> {
  final List<RTreeDatum<E>> _items = [];
  @override
  List<RTreeDatum<E>> get children => _items;

  LeafNode(int branchFactor, {List<RTreeDatum<E>> initialItems = const []}) : super(branchFactor) {
    if (initialItems.length > branchFactor) {
      throw ArgumentError('too many items');
    }
    for (final item in initialItems) {
      addChild(item);
    }
  }

  @override
  int get height => 1;

  @override
  Node<E> createNewNode() {
    return LeafNode<E>(branchFactor);
  }

  @override
  List<RTreeDatum<E>> search(Rectangle searchRect, bool Function(E item)? shouldInclude) {
    return _items
        .where((item) => item.rect.overlaps(searchRect) && (shouldInclude == null || shouldInclude(item.value)))
        .toList();
  }

  @override
  Node<E>? insert(RTreeDatum<E> item) {
    addChild(item);
    return splitIfNecessary();
  }

  @override
  void remove(RTreeDatum<E> item) {
    removeChild(item);
  }

  @override
  void clearChildren() {
    super.clearChildren();
    _items.clear();
  }
}
