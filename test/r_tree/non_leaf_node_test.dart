library non_leaf_node;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:test/test.dart';

main() {
  group('NonLeafNode', () {
    group('createNewNode', () {
      test('test that the right type of Node is created', () {
        NonLeafNode node = NonLeafNode(10);
        node.addChild(LeafNode(10));

        Node newNode = node.createNewNode();
        expect(newNode is NonLeafNode, equals(true));
        expect(newNode.size, equals(0));
        expect(newNode.branchFactor, equals(10));
      });
    });

    group('addChild/removeChild', () {
      test('adding/clearing children updates the rect', () {
        NonLeafNode node = NonLeafNode(3);

        expect(node.rect, equals(null));
        expect(node.size, equals(0));

        LeafNode leaf = LeafNode(3);
        leaf.addChild(RTreeDatum(Rectangle(0, 0, 1, 1), ''));
        node.addChild(leaf);

        expect(node.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));

        LeafNode nextChild = LeafNode(3);
        nextChild.addChild(RTreeDatum(Rectangle(1, 1, 1, 1), ''));
        node.addChild(nextChild);

        expect(node.rect, equals(Rectangle(0, 0, 2, 2)));
        expect(node.size, equals(2));

        node.removeChild(nextChild);

        expect(node.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));
        expect(node.search(Rectangle(1, 1, 1, 1)).length, equals(0));

        node.clearChildren();

        expect(node.rect, equals(null));
        expect(node.size, equals(0));
      });

      test('converting an empty NonLeafNode to a LeafNode', () {
        NonLeafNode parentNode = NonLeafNode(3);
        NonLeafNode node = NonLeafNode(3);
        node.parent = parentNode;
        parentNode.addChild(node);
        LeafNode leaf = LeafNode(3);
        node.addChild(leaf);

        var datum1 = RTreeDatum(Rectangle(0, 0, 1, 1), '');
        var datum2 = RTreeDatum(Rectangle(0, 0, 1, 2), '');
        node.insert(datum1);
        node.insert(datum2);

        parentNode.children.forEach((node) {
          expect(node, isInstanceOf<NonLeafNode>());
        });

        node.remove(datum1);
        node.remove(datum2);

        parentNode.children.forEach((node) {
          expect(node, isInstanceOf<LeafNode>());
        });
      });
    });
  });
}
