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

part of r_tree;

abstract class Node<E> extends RTreeContributor {
  final int branchFactor;

  Node<E> parent;
  Rectangle _minimumBoundingRect;
  Rectangle get rect => _minimumBoundingRect;

  Node(this.branchFactor);

  Iterable<RTreeDatum<E>> search(Rectangle searchRect);
  Node<E> insert(RTreeDatum<E> item);
  remove(RTreeDatum<E> item);
  clearChildren();
  List<RTreeContributor> get children;
  Node<E> createNewNode();

  int get size => children.length;

  addChild(covariant RTreeContributor child) {
    include(child);
    children.add(child);
  }

  removeChild(covariant RTreeContributor child) {
    children.remove(child);
    updateBoundingRect();
  }

  // Calculates the cost (increase to _minimumBoundingRect's area)
  // of adding a new @item to this Node
  num expansionCost(RTreeContributor item) {
    if (_minimumBoundingRect == null) {
      return _area(item.rect);
    }

    Rectangle newRect = _minimumBoundingRect.boundingBox(item.rect);
    return _area(newRect) - _area(_minimumBoundingRect);
  }

  num _area(Rectangle rect) => (rect.right - rect.left) * (rect.bottom - rect.top);

  // Adds the rectangle containing @item to this Node's _minimumBoundingRectangle
  include(RTreeContributor item) {
    _minimumBoundingRect =
        _minimumBoundingRect == null ? item.rect : _minimumBoundingRect.boundingBox(item.rect);
  }

  updateBoundingRect() {
    if (children.length == 0) return;

    _minimumBoundingRect = null;

    children.forEach((RTreeContributor child) {
      include(child);
    });
  }

  Node<E> splitIfNecessary() => size > branchFactor ? _split() : null;

  Node<E> _split() {
    _Seeds seeds = _pickSeeds();

    removeChild(seeds.seed1);
    removeChild(seeds.seed2);
    List<RTreeContributor> remainingChildren = children;

    clearChildren();
    addChild(seeds.seed1);

    Node<E> splitNode = createNewNode();
    splitNode.addChild(seeds.seed2);

    _reassignRemainingChildren(remainingChildren, splitNode);

    return splitNode;
  }

  _reassignRemainingChildren(List<RTreeContributor> remainingChildren, Node<E> splitNode) {
    remainingChildren.forEach((RTreeContributor child) {
      num thisExpansionCost = expansionCost(child);
      num splitExpansionCost = splitNode.expansionCost(child);

      if (thisExpansionCost < splitExpansionCost) {
        this.addChild(child);
      } else if (splitExpansionCost < thisExpansionCost) {
        splitNode.addChild(child);
      } else if (size < splitNode.size) {
        this.addChild(child);
      } else {
        splitNode.addChild(child);
      }
    });
  }

  _Seeds _pickSeeds() {
    RTreeContributor seed1;
    RTreeContributor seed2;

    RTreeContributor leftmost = children.elementAt(0);
    RTreeContributor rightmost = children.elementAt(0);
    RTreeContributor topmost = children.elementAt(0);
    RTreeContributor bottommost = children.elementAt(0);

    children.forEach((RTreeContributor child) {
      if (child.rect.right < leftmost.rect.right) leftmost = child;
      if (child.rect.left > rightmost.rect.left) rightmost = child;
      if (child.rect.top > bottommost.rect.top) bottommost = child;
      if (child.rect.bottom < topmost.rect.bottom) topmost = child;
    });

    RTreeContributor a, b, c, d;
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

    return new _Seeds(seed1, seed2);
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
