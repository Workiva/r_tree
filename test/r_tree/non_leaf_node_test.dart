library non_leaf_node;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:r_tree/src/r_tree/leaf_node.dart';
import 'package:r_tree/src/r_tree/node.dart';
import 'package:r_tree/src/r_tree/non_leaf_node.dart';
import 'package:test/test.dart';

void main() {
  group('NonLeafNode', () {
    group('createNewNode', () {
      test('test that the right type of Node is created', () {
        final node = NonLeafNode(10);
        node.addChild(LeafNode(10));

        final newNode = node.createNewNode();
        expect(newNode is NonLeafNode, equals(true));
        expect(newNode.size, equals(0));
        expect(newNode.branchFactor, equals(10));
      });
    });

    group('addChild/removeChild', () {
      test('adding/clearing children updates the rect', () {
        final node = NonLeafNode(3);

        expect(node.rect, equals(noMBR));
        expect(node.size, equals(0));

        final leaf = LeafNode(3);
        leaf.addChild(RTreeDatum(Rectangle(0, 0, 1, 1), ''));
        node.addChild(leaf);

        expect(node.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));

        final nextChild = LeafNode(3);
        nextChild.addChild(RTreeDatum(Rectangle(1, 1, 1, 1), ''));
        node.addChild(nextChild);

        expect(node.rect, equals(Rectangle(0, 0, 2, 2)));
        expect(node.size, equals(2));

        node.removeChild(nextChild);

        expect(node.rect, equals(Rectangle(0, 0, 1, 1)));
        expect(node.size, equals(1));
        expect(node.search(Rectangle(1, 1, 1, 1), (_) => true).length, equals(0));

        node.clearChildren();

        expect(node.rect, equals(noMBR));
        expect(node.size, equals(0));
      });
    });
  });
}
