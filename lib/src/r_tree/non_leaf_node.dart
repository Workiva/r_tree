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

import 'package:r_tree/src/r_tree/leaf_node.dart';
import 'package:r_tree/src/r_tree/node.dart';
import 'package:r_tree/src/r_tree/r_tree_datum.dart';
import 'package:r_tree/src/r_tree/rectangle_helper.dart';

/// A [Node] that is not a leaf end of the [RTree]. These are created automatically
/// by [RTree] when inserting/removing items from the tree.
@Deprecated('For internal use only, removed in next major release')
class NonLeafNode<E> extends Node<E> {
  final List<Node<E>> _childNodes = [];
  List<Node<E>> get children => _childNodes;

  NonLeafNode(int branchFactor, {List<Node<E>> initialChildNodes = const []}) : super(branchFactor) {
    if (initialChildNodes.length > branchFactor) {
      throw ArgumentError('too many items');
    }

    for (final child in initialChildNodes) {
      addChild(child);
    }
  }

  Node<E> createNewNode() {
    return NonLeafNode<E>(branchFactor);
  }

  Iterable<RTreeDatum<E>> search(Rectangle searchRect, bool Function(E item)? shouldInclude) {
    List<RTreeDatum<E>> overlappingLeafs = [];

    for (var childNode in _childNodes) {
      if (childNode.rect.overlaps(searchRect)) {
        overlappingLeafs.addAll(childNode.search(searchRect, shouldInclude));
      }
    }

    return overlappingLeafs;
  }

  Node<E>? insert(RTreeDatum<E> item) {
    include(item);

    Node<E> bestNode = _getBestNodeForInsert(item);
    Node<E>? splitNode = bestNode.insert(item);

    if (splitNode != null) {
      addChild(splitNode);
    }

    return splitIfNecessary();
  }

  remove(RTreeDatum<E> item) {
    List<Node<E>> childrenToRemove = [];

    for (var childNode in _childNodes) {
      if (childNode.rect.overlaps(item.rect)) {
        childNode.remove(item);

        if (childNode.size == 0) {
          childrenToRemove.add(childNode);
        }
      }
    }

    for (var child in childrenToRemove) {
      removeChild(child);
    }

    _updateHeightAndBounds();
  }

  addChild(Node<E> child) {
    super.addChild(child);
    child.parent = this;
  }

  removeChild(Node<E> child) {
    super.removeChild(child);
    child.parent = null;

    _updateHeightAndBounds();
  }

  clearChildren() {
    super.clearChildren();
    _childNodes.clear();
    _minimumBoundingRect = noMBR;
  }

  Node<E> _getBestNodeForInsert(RTreeDatum<E> item) {
    Node<E> bestNode = _childNodes[0];
    num bestCost = bestNode.expansionCost(item);

    for (var i = 1; i < _childNodes.length; i++) {
      final child = _childNodes[i];
      final tentativeCost = child.expansionCost(item);
      if (tentativeCost < bestCost) {
        bestCost = tentativeCost;
        bestNode = child;
      }
    }

    return bestNode;
  }

  _updateHeightAndBounds() {
    var maxChildHeight = 0;
    for (final childNode in _childNodes) {
      maxChildHeight = max(maxChildHeight, childNode.height);
    }
    this.height = 1 + maxChildHeight;

    updateBoundingRect();
  }
}
