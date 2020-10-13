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

/// A [Node] that is not a leaf end of the [RTree]. These are created automatically
/// by [RTree] when inserting/removing items from the tree.
class NonLeafNode<E> extends Node<E> {
  List<Node<E>> _childNodes = [];
  List<Node<E>> get children => _childNodes;

  NonLeafNode(int branchFactor) : super(branchFactor);

  Node<E> createNewNode() {
    return new NonLeafNode<E>(branchFactor);
  }

  Iterable<RTreeDatum<E>> search(
      Rectangle searchRect, bool Function(E item) shouldInclude) {
    List<RTreeDatum<E>> overlappingLeafs = [];

    for (var childNode in _childNodes) {
      if (childNode.overlaps(searchRect)) {
        overlappingLeafs.addAll(childNode.search(searchRect, shouldInclude));
      }
    }

    return overlappingLeafs;
  }

  Node<E> insert(RTreeDatum<E> item) {
    include(item);

    Node<E> bestNode = _getBestNodeForInsert(item);
    Node<E> splitNode = bestNode.insert(item);

    if (splitNode != null) {
      addChild(splitNode);
    }

    return splitIfNecessary();
  }

  remove(RTreeDatum<E> item) {
    List<Node<E>> childrenToRemove = [];

    for (var childNode in _childNodes) {
      if (childNode.overlaps(item.rect)) {
        childNode.remove(item);

        if (childNode.size == 0) {
          childrenToRemove.add(childNode);
        }
      }
    }

    for (var child in childrenToRemove) {
      removeChild(child);
    }
  }

  addChild(Node<E> child) {
    super.addChild(child);
    child.parent = this;
  }

  removeChild(Node<E> child) {
    super.removeChild(child);
    child.parent = null;

    if (_childNodes.length == 0) {
      _convertToLeafNode();
    }
  }

  clearChildren() {
    _childNodes = [];
    _minimumBoundingRect = null;
  }

  Node<E> _getBestNodeForInsert(RTreeDatum<E> item) {
    num bestCost = core_constant.double.infinity;
    num tentativeCost;
    Node<E> bestNode;

    for (var child in _childNodes) {
      tentativeCost = child.expansionCost(item);
      if (tentativeCost < bestCost) {
        bestCost = tentativeCost;
        bestNode = child;
      }
    }

    return bestNode;
  }

  _convertToLeafNode() {
    var nonLeafParent = parent as NonLeafNode<E>;
    if (nonLeafParent == null) return;

    var newLeafNode = new LeafNode<E>(this.branchFactor);
    newLeafNode.include(this);
    nonLeafParent.removeChild(this);
    nonLeafParent.addChild(newLeafNode);
  }
}
