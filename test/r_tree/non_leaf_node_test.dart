library non_leaf_node;

import 'package:r_tree/r_tree.dart';
import 'package:unittest/unittest.dart';
import 'dart:math';

main() {
  group('NonLeafNode', () {
    group('createNewNode', () {
      test('test that the right type of Node is created', () {
        NonLeafNode node = new NonLeafNode(10);
        node.addChild(new LeafNode(10));

        Node newNode = node.createNewNode();
        expect(newNode is NonLeafNode, equals(true));
        expect(newNode.size, equals(0));
        expect(newNode.branchFactor, equals(10));
      });
    });

    group('addChild/removeChild', () {
      test('adding/clearing children updates the rect', () {
        NonLeafNode node = new NonLeafNode(3);

        expect(node.rect, equals(null));
        expect(node.size, equals(0));

        LeafNode leaf = new LeafNode(3);
        leaf.addChild(new RTreeDatum(new Rectangle(0, 0, 1, 1), ''));
        node.addChild(leaf);

        expect(node.rect, equals(new Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));

        LeafNode nextChild = new LeafNode(3);
        nextChild.addChild(new RTreeDatum(new Rectangle(1, 1, 1, 1), ''));
        node.addChild(nextChild);

        expect(node.rect, equals(new Rectangle(0, 0, 2, 2)));
        expect(node.size, equals(2));

        node.removeChild(nextChild);

        expect(node.rect, equals(new Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));
        expect(node.search(new Rectangle(1, 1, 1, 1)).length, equals(0));

        node.clearChildren();

        expect(node.rect, equals(null));
        expect(node.size, equals(0));
      });

      test('converting an empty NonLeafNode to a LeafNode', () {
        NonLeafNode parentNode = new NonLeafNode(3);
        NonLeafNode node = new NonLeafNode(3);
        node.parent = parentNode;
        parentNode.addChild(node);
        LeafNode leaf = new LeafNode(3);
        node.addChild(leaf);

        var datum1 = new RTreeDatum(new Rectangle(0, 0, 1, 1), '');
        var datum2 = new RTreeDatum(new Rectangle(0, 0, 1, 2), '');
        node.insert(datum1);
        node.insert(datum2);

        parentNode.children.forEach((node) {
          expect(node, new isInstanceOf<NonLeafNode>());
        });

        node.remove(datum1);
        node.remove(datum2);

        parentNode.children.forEach((node) {
          expect(node, new isInstanceOf<LeafNode>());
        });
      });
    });
  });
}