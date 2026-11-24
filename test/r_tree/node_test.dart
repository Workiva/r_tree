import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:r_tree/src/r_tree/leaf_node.dart';
import 'package:test/test.dart';

void main() {
  group('Node', () {
    group('splitIfNecessary', () {
      test('split should not occur until branchFactor is exceeded', () {
        final leafNode = LeafNode(10);
        final itemMap = {};

        for (var i = 0; i < 4; i++) {
          final itemId = 'Item $i';
          final item = RTreeDatum<String>(Rectangle(0, i, 1, 1), itemId);
          itemMap[itemId] = item;
          leafNode.addChild(item);
        }

        expect(leafNode.size, equals(4));
        expect(leafNode.splitIfNecessary(), equals(null));
      });

      test('test that split correctly splits a column', () {
        final leafNode = LeafNode(3);
        final itemMap = {};

        for (var i = 0; i < 4; i++) {
          final itemId = 'Item $i';
          final item = RTreeDatum<String>(Rectangle(0, i, 1, 1), itemId);
          itemMap[itemId] = item;
          leafNode.addChild(item);
        }

        expect(leafNode.size, equals(4));

        final splitNode = leafNode.splitIfNecessary()! as LeafNode<dynamic>;

        Iterable<RTreeDatum?> items = leafNode.search(Rectangle(0, 0, 1, 10), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(Rectangle(0, 0, 1, 10), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });

      test('test that split correctly splits a row', () {
        final leafNode = LeafNode(3);
        final itemMap = {};

        for (var i = 0; i < 4; i++) {
          final itemId = 'Item $i';
          final item = RTreeDatum<String>(Rectangle(i, 0, 1, 1), itemId);
          itemMap[itemId] = item;
          leafNode.addChild(item);
        }

        expect(leafNode.size, equals(4));

        final splitNode = leafNode.splitIfNecessary()! as LeafNode<dynamic>;

        Iterable<RTreeDatum?> items = leafNode.search(Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });

      test('test that split correctly splits a random cluster', () {
        final leafNode = LeafNode(3);
        final itemMap = {};

        for (var i = 0; i < 4; i++) {
          final itemId = 'Item $i';
          final item = RTreeDatum<String>(Rectangle(i, 0, 1, 1), itemId);
          itemMap[itemId] = item;
          leafNode.addChild(item);
        }

        expect(leafNode.size, equals(4));

        final splitNode = leafNode.splitIfNecessary()! as LeafNode<dynamic>;

        Iterable<RTreeDatum?> items = leafNode.search(Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(leafNode.size));
        expect(leafNode.size, equals(2));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));

        items = splitNode.search(Rectangle(0, 0, 10, 1), (_) => true);
        expect(items.length, equals(splitNode.size));
        expect(splitNode.size, equals(2));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
      });
    });

    group('expansionCost', () {
      test('expansionCost correctly calculated', () {
        final node = LeafNode(3);

        expect(node.expansionCost(RTreeDatum(Rectangle(0, 0, 1, 1), '')), equals(1));

        node.addChild(RTreeDatum(Rectangle(0, 0, 1, 1), ''));

        expect(node.expansionCost(RTreeDatum(Rectangle(0, 0, 1, 1), '')), equals(0));
        expect(node.expansionCost(RTreeDatum(Rectangle(1, 1, 1, 1), '')), equals(3));

        node.addChild(RTreeDatum(Rectangle(2, 2, 1, 1), ''));

        expect(node.expansionCost(RTreeDatum(Rectangle(1, 1, 3, 3), '')), equals(7));
      });
    });
  });
}
