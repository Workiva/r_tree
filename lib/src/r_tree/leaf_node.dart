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

class LeafNode<E> extends Node<E> {
  List<RTreeDatum<E>> _items = [];
  List<RTreeDatum<E>> get children => _items;

  LeafNode(int branchFactor) : super(branchFactor);

  Node<E> createNewNode() {
    return new LeafNode<E>(branchFactor);
  }

  Iterable<RTreeDatum<E>> search(Rectangle searchRect) {
    return _items.where((RTreeDatum<E> item) => item.overlaps(searchRect));
  }

  Node<E> insert(RTreeDatum<E> item) {
    addChild(item);
    return splitIfNecessary();
  }

  remove(RTreeDatum<E> item) {
    removeChild(item);
  }

  clearChildren() {
    _items = [];
    _minimumBoundingRect = null;
  }
}
