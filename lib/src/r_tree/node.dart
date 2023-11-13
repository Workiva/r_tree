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

import 'package:r_tree/src/r_tree/r_tree_contributor.dart';
import 'package:r_tree/src/r_tree/r_tree_datum.dart';
import 'package:r_tree/src/r_tree/rectangle_helper.dart';

const noMBR = Rectangle<num>(0, 0, 0, 0);

/// A [Node] is an entry in a tree for a particular rectangle.  This is an
/// abstract class, see LeafNode and NonLeafNode for more information.
abstract class Node<E> implements RTreeContributor {
  /// The branch factor this node is configured with, which determines when the node should split
  final int branchFactor;

  /// Height of the node, where 1 is a leaf node
  int height = 1;

  /// Parent node of this node, or null if this is the root node
  Node<E>? parent;

  Rectangle _minimumBoundingRect = noMBR;

  /// Returns the rectangle this Node covers
  @override
  Rectangle get rect => _minimumBoundingRect;

  void setRect(Rectangle<num> rect) => _minimumBoundingRect = rect;

  Node(this.branchFactor);

  /// Returns an iterable of all items within [searchRect]
  Iterable<RTreeDatum<E>> search(Rectangle searchRect, bool Function(E item)? shouldInclude);

  /// Inserts [item] into the node. If the insertion causes a split to occur, the split node will be returned, otherwise null is returned.
  Node<E>? insert(RTreeDatum<E> item);

  /// Removes [item] from this node
  void remove(RTreeDatum<E> item);

  /// Remove all children from this node
  void clearChildren() {
    _minimumBoundingRect = noMBR;
  }

  /// Returns a list of all items in this node
  List<RTreeContributor> get children;

  /// Factory method for creating a new node (used when splitting the node)
  Node<E> createNewNode();

  /// The size of the node is its child count
  int get size => children.length;

  /// Adds [child] to this node
  void addChild(covariant RTreeContributor child) {
    include(child);
    children.add(child);
  }

  /// Removes [child] from this node
  void removeChild(covariant RTreeContributor child) {
    children.remove(child);
    updateBoundingRect();
  }

  /// Calculates the cost (increase to _minimumBoundingRect's area)
  /// of adding a new @item to this Node
  num expansionCost(RTreeContributor item) {
    if (_minimumBoundingRect == noMBR) {
      return item.rect.area();
    }

    final newRect = rect.boundingBox(item.rect);
    return newRect.area() - rect.area();
  }

  num area() => rect.area();

  num get margin => (rect.right - rect.left) + (rect.bottom - rect.top);

  /// Adds the rectangle containing [item] to this node's covered rectangle
  void include(RTreeContributor item) {
    _minimumBoundingRect = _minimumBoundingRect == noMBR ? item.rect : rect.boundingBox(item.rect);
  }

  /// Recalculated the bounding rectangle of this node
  Rectangle updateBoundingRect() {
    _minimumBoundingRect = noMBR;
    if (children.isEmpty) {
      return _minimumBoundingRect;
    }

    _minimumBoundingRect = children[0].rect;
    for (var i = 1; i < children.length; i++) {
      _minimumBoundingRect = _minimumBoundingRect.boundingBox(children[i].rect);
    }

    return _minimumBoundingRect;
  }

  void extend(Rectangle b) {
    _minimumBoundingRect = rect.boundingBox(b);
  }

  /// Determines if this node needs to be split and returns a new [Node] if so, otherwise returns null
  Node<E>? splitIfNecessary() => size > branchFactor ? _split() : null;

  Node<E> _split() {
    final seeds = _pickSeeds();

    removeChild(seeds.seed1);
    removeChild(seeds.seed2);
    final remainingChildren = children.toList();

    clearChildren();
    addChild(seeds.seed1);

    final splitNode = createNewNode();
    splitNode.height = height;
    splitNode.addChild(seeds.seed2);

    _reassignRemainingChildren(remainingChildren, splitNode);

    return splitNode;
  }

  void _reassignRemainingChildren(List<RTreeContributor> remainingChildren, Node<E> splitNode) {
    for (final child in remainingChildren) {
      final thisExpansionCost = expansionCost(child);
      final splitExpansionCost = splitNode.expansionCost(child);

      if (thisExpansionCost < splitExpansionCost) {
        this.addChild(child);
      } else if (splitExpansionCost < thisExpansionCost) {
        splitNode.addChild(child);
      } else if (size < splitNode.size) {
        this.addChild(child);
      } else {
        splitNode.addChild(child);
      }
    }
  }

  _Seeds _pickSeeds() {
    RTreeContributor seed1;
    RTreeContributor seed2;

    var leftmost = children.elementAt(0);
    var rightmost = children.elementAt(0);
    var topmost = children.elementAt(0);
    var bottommost = children.elementAt(0);

    for (final child in children) {
      if (child.rect.right < leftmost.rect.right) leftmost = child;
      if (child.rect.left > rightmost.rect.left) rightmost = child;
      if (child.rect.top > bottommost.rect.top) bottommost = child;
      if (child.rect.bottom < topmost.rect.bottom) topmost = child;
    }

    RTreeContributor? a, b, c, d;
    if (_horizontalDifference(leftmost, rightmost) > _verticalDifference(topmost, bottommost)) {
      a = leftmost;
      b = rightmost;
      c = bottommost;
      d = topmost;
    } else {
      a = topmost;
      b = bottommost;
      c = leftmost;
      d = rightmost;
    }

    if (a != b) {
      seed1 = a;
      seed2 = b;
    } else if (c != d) {
      seed1 = c;
      seed2 = d;
    } else {
      seed1 = children.elementAt(0);
      seed2 = children.elementAt(1);
    }

    return _Seeds(seed1, seed2);
  }

  num _horizontalDifference(RTreeContributor leftmost, RTreeContributor rightmost) =>
      (rightmost.rect.left - leftmost.rect.right).abs();

  num _verticalDifference(RTreeContributor topmost, RTreeContributor bottommost) =>
      (topmost.rect.bottom - bottommost.rect.top).abs();
}

class _Seeds {
  final RTreeContributor seed1;
  final RTreeContributor seed2;

  const _Seeds(this.seed1, this.seed2);
}
