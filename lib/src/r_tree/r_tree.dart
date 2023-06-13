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

/// A two dimensional index of data that allows querying by rectangular areas
class RTree<E> {
  Node<E> _root;
  int _branchFactor;

  RTree([int branchFactor = 16]) {
    if (branchFactor < 3) {
      throw ArgumentError('branchFactor must be greater than 2');
    }
    _branchFactor = branchFactor;
    _resetRoot();
  }

  String toGraphViz() {
    var output = StringBuffer('''digraph r_tree {
    root [
        color="gray"
        label="root"
    ]
    ''');
    _graphVizRecurse(_root, 'root', 'root', output);

    output.write('}');

    return output.toString();
  }

  void _graphVizRecurse(
      Node node, String parent, String identifierPrefix, StringBuffer buffer) {
    for (var i = 0; i < node.children.length; i++) {
      var child = node.children[i];
      if (child is LeafNode) {
        var id = "${identifierPrefix}LeafNode$i";
        buffer.write('''
      $id [
        color="green"
        label="LeafNode$i"
      ]
      $parent -> $id
''');
        for (var j = 0; j < child.children.length; j++) {
          var leafChild = child.children[j];
          var childId = "${id}LeafChild$j";
          buffer.write('''
"$childId" [
  color="orange"
  label="${leafChild.value}"
]
$id -> "$childId"
''');
        }
      } else if (child is NonLeafNode) {
        var id = "${identifierPrefix}ChildNode$i";
        buffer.write('''
 $id [
  color="brown"
  label="ChildNode$i"
 ]
 $parent -> $id
''');
        _graphVizRecurse(child, id, id, buffer);
      } else if (child is RTreeDatum) {
        var id = "${identifierPrefix}Datum$i";
        buffer.write('''
"$id" [
  color="orange"
  label="${child.value}"
]
$parent -> "$id"
''');
      }
    }
  }

  Node<E> get root => _root;

  remove(RTreeDatum<E> item) {
    _root.remove(item);

    if (_root.children.length == 0) {
      _resetRoot();
    }
  }

  insert(RTreeDatum<E> item) {
    Node<E> splitNode = _root.insert(item);

    if (splitNode != null) {
      _growTree(_root, splitNode);
    }
  }

  load(Iterable<RTreeDatum<E>> items) {
    items.forEach(insert);
  }

  _resetRoot() {
    _root = LeafNode<E>(_branchFactor);
  }

  // Returns all items whose rectangles overlap the @searchRect
  //  Note: Rectangles that share only a border are not considered to overlap
  Iterable<RTreeDatum<E>> search(Rectangle searchRect,
      {bool Function(E item) shouldInclude}) {
    shouldInclude ??= (_) => true;

    if (_root is LeafNode<E>) {
      return _root.search(searchRect, shouldInclude).toList();
    }

    return _root.search(searchRect, shouldInclude);
  }

  _growTree(Node<E> node1, Node<E> node2) {
    NonLeafNode<E> newRoot = NonLeafNode<E>(_branchFactor);
    newRoot.addChild(node1);
    newRoot.addChild(node2);
    _root = newRoot;
  }
}
