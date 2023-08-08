library leaf_node;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:test/test.dart';

main() {
  group('LeafNode', () {
    group('createNewNode', () {
      test('test that the right type of Node is created', () {
        LeafNode leafNode = LeafNode(10);
        leafNode.addChild(RTreeDatum(Rectangle(0, 0, 1, 1), 'Item 1'));

        Node newNode = leafNode.createNewNode();
        expect(newNode is LeafNode, equals(true));
        expect(newNode.size, equals(0));
        expect(newNode.branchFactor, equals(10));
      });
    });

    group('addChild/removeChild', () {
      test('adding/clearing children updates the rect', () {
        LeafNode leaf = LeafNode(3);

        expect(leaf.rect, equals(Rectangle(0, 0, 0, 0)));
        expect(leaf.size, equals(0));

        leaf.addChild(RTreeDatum(Rectangle(0, 0, 1, 1), 'Item 1'));

        expect(leaf.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(leaf.size, equals(1));

        RTreeDatum nextChild = RTreeDatum(Rectangle(1, 1, 1, 1), 'Item 1');
        leaf.addChild(nextChild);

        expect(leaf.rect, equals(Rectangle(0, 0, 2, 2)));
        expect(leaf.size, equals(2));

        leaf.removeChild(nextChild);

        expect(leaf.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(leaf.size, equals(1));
        expect(leaf.search(Rectangle(1, 1, 1, 1), (_) => true).length, equals(0));

        leaf.clearChildren();

        expect(leaf.rect, equals(Rectangle(0, 0, 0, 0)));
        expect(leaf.size, equals(0));
      });
    });
  });
}
