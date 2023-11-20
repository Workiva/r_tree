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
import 'package:r_tree/src/r_tree/non_leaf_node.dart';
import 'package:r_tree/src/r_tree/quickselect.dart';
import 'package:r_tree/src/r_tree/r_tree_datum.dart';
import 'package:r_tree/src/r_tree/rectangle_helper.dart';

/// A two dimensional index of data that allows querying by rectangular areas
class RTree<E> {
  final int _branchFactor;
  late Node<E> _root;
  late int _minEntries;

  RTree([int branchFactor = 16]) : _branchFactor = branchFactor {
    if (branchFactor < 3) {
      throw ArgumentError('branchFactor must be greater than 2');
    }
    _minEntries = max(2, (max(4, _branchFactor) * 0.4).ceil());
    _resetRoot();
  }

  /// Adds all [items] to the rtree
  void add(List<RTreeDatum<E>> items) {
    if (items.length == 1) {
      _insert(items.first);
      return;
    }

    _load(items);
  }

  /// Removes [item] from the rtree
  void remove(RTreeDatum<E> item) {
    _root.remove(item);

    if (_root.children.isEmpty) {
      _resetRoot();
    }
  }

  /// Adds [item] to the rtree
  void _insert(RTreeDatum<E> item) {
    final splitNode = _root.insert(item);

    if (splitNode != null) {
      _growTree(_root, splitNode);
    }
  }

  /// Returns all items whose rectangles overlap [searchRect]
  /// If [shouldInclude] is specified, each item will be passed to the
  /// method and excluded if [shouldInclude] evaluates to false.
  ///
  /// Note: Rectangles that share only a border are not considered to overlap
  List<RTreeDatum<E>> search(Rectangle searchRect, {bool Function(E item)? shouldInclude}) {
    shouldInclude ??= (_) => true;

    if (_root is LeafNode<E>) {
      return _root.search(searchRect, shouldInclude);
    }

    return _root.search(searchRect, shouldInclude);
  }

  /// Bulk adds all [items] to the rtree. This implementation draws heavily from
  /// https://github.com/mourner/rbush and https://github.com/Zverik/dart_rbush.
  void _load(List<RTreeDatum<E>> items) {
    if (items.isEmpty) {
      return;
    }

    if (items.length < _minEntries) {
      for (final item in items) {
        _insert(item);
      }
      return;
    }

    // recursively build the tree with the given data from scratch using OMT algorithm
    var node = _build(items, 0, items.length - 1, 0);

    if (_root.children.isEmpty) {
      // save as is if tree is empty
      _root = node;
    } else if (_root.height == node.height) {
      // split root if trees have the same height
      _growTree(_root, node);
    } else {
      if (_root.height < node.height) {
        // swap trees if inserted one is bigger
        final tmpNode = _root;
        _root = node;
        node = tmpNode;
      }

      // insert the small tree into the large tree at appropriate level
      _insertTree(_root.height - node.height - 1, node);
    }

    return;
  }

  void _insertTree(int level, Node<E> inode) {
    final insertPath = <Node<E>>[];

    // find the best node for accommodating the item, saving all nodes along the path too
    final node = _chooseSubtree(inode, _root, level, insertPath);

    node.children.add(inode);
    node.updateBoundingRect();
    inode.parent = node;

    // split on node overflow; propagate upwards if necessary
    while (level >= 0) {
      if (insertPath[level].children.length > _branchFactor) {
        _split(insertPath, level);
        level--;
      } else {
        break;
      }
    }

    // fix all the bounding rectangles along the insertion path
    for (final e in insertPath.reversed) {
      e.updateBoundingRect();
    }
  }

  Node<E> _chooseSubtree(Node<E> inode, Node<E> node, int level, List<Node<E>> path) {
    while (true) {
      path.add(node);

      if (node is LeafNode || path.length - 1 == level) {
        break;
      }

      final nonLeafNode = node as NonLeafNode<E>;

      num minArea = double.infinity;
      num minEnlargement = double.infinity;
      Node<E>? targetNode;

      // no leaves here
      for (final child in nonLeafNode.children) {
        if (child is NonLeafNode<E>) {
          final area = child.rect.width * child.rect.height;
          final enlargement = inode.expansionCost(child);

          // choose entry with the least area enlargement
          if (enlargement < minEnlargement) {
            minEnlargement = enlargement;
            minArea = area < minArea ? area : minArea;
            targetNode = child;
          } else if (enlargement == minEnlargement) {
            // otherwise choose one with the smallest area
            if (area < minArea) {
              minArea = area;
              targetNode = child;
            }
          }
        }
      }

      node = targetNode ?? nonLeafNode.children.first;
    }

    return node;
  }

  Node<E> _build(List<RTreeDatum<E>> items, int left, int right, int height, [NonLeafNode<E>? parent]) {
    final N = right - left + 1;
    var M = _branchFactor;
    NonLeafNode<E> node;

    if (N <= M) {
      // reached leaf level; return leaf
      return LeafNode(
        _branchFactor,
        initialItems: items.sublist(left, right + 1),
      )..parent = parent;
    }

    if (height == 0) {
      // target height of the bulk-loaded tree
      height = (log(N) / log(M)).ceil();

      // target number of root entries to maximize storage utilization
      M = (N / pow(M, height - 1)).ceil();
    }

    node = NonLeafNode(_branchFactor)
      ..height = height
      ..parent = parent;

    // split the items into M mostly square tiles

    final n2 = (N.toDouble() / M).ceil();
    final n1 = n2 * sqrt(M).ceil();

    multiSelect(items, left, right, n1, _compareRectLeft);

    for (var i = left; i <= right; i += n1) {
      final right2 = min(i + n1 - 1, right);

      multiSelect(items, i, right2, n2, _compareRectTop);

      for (var j = i; j <= right2; j += n2) {
        final right3 = min(j + n2 - 1, right2);

        // pack each entry recursively
        node.children.add(_build(items, j, right3, height - 1, node));
      }
    }
    node.updateBoundingRect();

    return node;
  }

  /// split overflowed node into two
  void _split(List<Node<E>> insertPath, int level) {
    final node = insertPath[level];
    final M = node.children.length;
    final m = _minEntries;

    _chooseSplitAxis(node, m, M);

    final splitIndex = _chooseSplitIndex(node, m, M);

    Node<E> newNode;
    if (node is LeafNode) {
      newNode = LeafNode<E>(_branchFactor, initialItems: node.children.cast<RTreeDatum<E>>().sublist(splitIndex));
      node.children.removeRange(splitIndex, node.children.length);
    } else {
      newNode = NonLeafNode(_branchFactor, initialChildNodes: node.children.cast<Node<E>>().sublist(splitIndex));
      node.children.removeRange(splitIndex, node.children.length);
    }
    newNode.height = node.height;

    node.updateBoundingRect();
    newNode.updateBoundingRect();

    if (level > 0) {
      insertPath[level - 1].addChild(newNode);
    } else {
      _splitRoot(node, newNode);
    }
  }

  /// Split root node
  void _splitRoot(Node<E> node, Node<E> newNode) {
    _root = NonLeafNode<E>(_branchFactor, initialChildNodes: [node, newNode]);
    _root.height = node.height + 1;
  }

  int _chooseSplitIndex(Node<E> node, int m, int M) {
    int? index;
    num minOverlap = double.infinity;
    num minArea = double.infinity;

    for (var i = m; i <= M - m; i++) {
      final bbox1 = _boundingBoxForDistribution(node, 0, i);
      final bbox2 = _boundingBoxForDistribution(node, i, M);

      final intersection = bbox1.intersection(bbox2);
      final overlap = intersection != null ? intersection.area() : 0;
      final area = bbox1.area() + bbox2.area();

      // choose distribution with minimum overlap
      if (overlap < minOverlap) {
        minOverlap = overlap;
        index = i;

        minArea = area < minArea ? area : minArea;
      } else if (overlap == minOverlap) {
        // otherwise choose distribution with minimum area
        if (area < minArea) {
          minArea = area;
          index = i;
        }
      }
    }

    return index ?? M - m;
  }

  void _chooseSplitAxis(Node<E> node, int m, int M) {
    final xMargin = _allDistributionMargins(node, m, M, true);
    final yMargin = _allDistributionMargins(node, m, M, false);

    // if total distributions margin value is minimal for x, sort by minX,
    // otherwise it's already sorted by minY
    if (xMargin < yMargin) {
      _sortChildrenBy(node, true);
    }
  }

  void _sortChildrenBy(Node<E> node, bool sortByMinX) {
    if (sortByMinX) {
      node.children.sort((a, b) => a.rect.left.compareTo(b.rect.left));
    } else {
      node.children.sort((a, b) => a.rect.top.compareTo(b.rect.top));
    }
  }

  /// total margin of all possible split distributions where each node is at least [m] full
  num _allDistributionMargins(Node<E> node, int m, int M, bool sortByMinX) {
    _sortChildrenBy(node, sortByMinX);

    final leftBoundingBox = _boundingBoxForDistribution(node, 0, m);
    final rightBoundingBox = _boundingBoxForDistribution(node, M - m, M);
    num calculateMargin(Rectangle rect) => (rect.right - rect.left) + (rect.bottom - rect.top);

    var margin = calculateMargin(leftBoundingBox) + calculateMargin(rightBoundingBox);

    for (var i = m; i < M - m; i++) {
      leftBoundingBox.boundingBox(node is LeafNode ? node.children[i].rect : node.children[i].rect);
      margin += calculateMargin(leftBoundingBox);
    }

    for (var i = M - m - 1; i >= m; i--) {
      rightBoundingBox.boundingBox(node.children[i].rect);
      margin += calculateMargin(rightBoundingBox);
    }

    return margin;
  }

  Rectangle _boundingBoxForDistribution(Node<E> node, int startChild, int stopChild) {
    return node.children.sublist(startChild, stopChild).fold(
          node.children[startChild].rect,
          (previousValue, element) => previousValue.boundingBox(element.rect),
        );
  }

  void _resetRoot() {
    _root = LeafNode<E>(_branchFactor);
  }

  void _growTree(Node<E> node1, Node<E> node2) {
    final newRoot = NonLeafNode<E>(_branchFactor, initialChildNodes: [node1, node2]);
    newRoot.height = _root.height + 1;
    _root = newRoot;
    node1.parent = _root;
    node2.parent = _root;
  }
}

@pragma('vm:prefer-inline')
int _compareNumber(num a, num b) {
  if (a == b) {
    return 0;
  }

  return a > b ? 1 : -1;
}

@pragma('vm:prefer-inline')
int _compareRectTop(RTreeDatum a, RTreeDatum b) => _compareNumber(a.rect.top, b.rect.top);

@pragma('vm:prefer-inline')
int _compareRectLeft(RTreeDatum a, RTreeDatum b) => _compareNumber(a.rect.left, b.rect.left);

/// Helper for example app to generate GraphViz
Node getCurrentRootNode(RTree tree) => tree._root;
