library node_test;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:test/test.dart';

main() {
  group('Node', () {
    group('splitIfNecessary', () {
      test('split should not occur until branchFactor is exceeded', () {
        LeafNode leafNode = new LeafNode(10);
        Map itemMap = new Map();

        for (int i = 0; i < 4; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(0, i, 1, 1), itemId);
          leafNode.addChild(itemMap[itemId]);
        }

        expect(leafNode.size, equals(4));
        expect(leafNode.splitIfNecessary(), equals(null));
      });

      test('test that split correctly splits a column', () {
        LeafNode leafNode = new LeafNode(3);
        Map itemMap = new Map();

        for (int i = 0; i < 4; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(0, i, 1, 1), itemId);
          leafNode.addChild(itemMap[itemId]);
        }

        expect(leafNode.size, equals(4));

        LeafNode splitNode = leafNode.splitIfNecessary();

        Iterable<RTreeDatum> items =
            leafNode.search(new Rectangle(0, 0, 1, 10), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(new Rectangle(0, 0, 1, 10), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });

      test('test that split correctly splits a row', () {
        LeafNode leafNode = new LeafNode(3);
        Map itemMap = new Map();

        for (int i = 0; i < 4; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(i, 0, 1, 1), itemId);
          leafNode.addChild(itemMap[itemId]);
        }

        expect(leafNode.size, equals(4));

        LeafNode splitNode = leafNode.splitIfNecessary();

        Iterable<RTreeDatum> items =
            leafNode.search(new Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(new Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });

      test('test that split correctly splits a random cluster', () {
        LeafNode leafNode = new LeafNode(3);
        Map itemMap = new Map();

        for (int i = 0; i < 4; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(i, 0, 1, 1), itemId);
          leafNode.addChild(itemMap[itemId]);
        }

        expect(leafNode.size, equals(4));

        LeafNode splitNode = leafNode.splitIfNecessary();

        Iterable<RTreeDatum> items =
            leafNode.search(new Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(new Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });
    });

    group('expansionCost', () {
      test('expansionCost correctly calculated', () {
        LeafNode node = new LeafNode(3);

        expect(
            node.expansionCost(new RTreeDatum(new Rectangle(0, 0, 1, 1), '')),
            equals(1));

        node.addChild(new RTreeDatum(new Rectangle(0, 0, 1, 1), ''));

        expect(
            node.expansionCost(new RTreeDatum(new Rectangle(0, 0, 1, 1), '')),
            equals(0));
        expect(
            node.expansionCost(new RTreeDatum(new Rectangle(1, 1, 1, 1), '')),
            equals(3));

        node.addChild(new RTreeDatum(new Rectangle(2, 2, 1, 1), ''));

        expect(
            node.expansionCost(new RTreeDatum(new Rectangle(1, 1, 3, 3), '')),
            equals(7));
      });
    });
  });
}
