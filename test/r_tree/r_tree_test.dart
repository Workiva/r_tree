library r_tree;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:test/test.dart';

main() {
  group('RTree', () {
    group('Insert/Search', () {
      test('insert 1 item', () {
        RTree tree = new RTree(3);
        RTreeDatum<String> item =
            new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 1');

        tree.insert(item);
        var items = tree.search(item.rect, (_) => false);
        expect(items, isEmpty);

        items = tree.search(item.rect);

        expect(items.length, equals(1));
        expect(items.elementAt(0).value, equals('Item 1'));

        items.forEach((item) {
          tree.insert(
              new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 2'));
          tree.insert(
              new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 3'));
          tree.insert(
              new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 4'));
          tree.insert(
              new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 5'));
        });

        items = tree.search(item.rect);
        expect(items.length, equals(5));

        items.forEach((item) {
          tree.remove(item);
        });

        items = tree.search((item.rect));
        expect(items.isEmpty, isTrue);
      });

      test('search for 1 cell in large format ranges', () {
        RTree tree = new RTree(3);
        Map itemMap = new Map();

        for (int i = 0; i < 10; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(i, 0, 10 - i, 10), itemId);
          tree.insert(itemMap[itemId]);
        }

        var items = tree.search(new Rectangle(0, 0, 1, 3)); // A1:A3
        expect(items.length, equals(1));
        expect(items.contains(itemMap['Item 0']), equals(true));

        items = tree.search(new Rectangle(0, 3, 1, 10)); // A3:A13
        expect(items.length, equals(1));
        expect(items.contains(itemMap['Item 0']), equals(true));

        items = tree.search(new Rectangle(4, 4, 1, 1)); // E5
        expect(items.length, equals(5));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
        expect(items.contains(itemMap['Item 4']), equals(true));
      });

      test('insert enough items to cause split', () {
        RTree tree = new RTree(3);
        Map itemMap = new Map();

        for (int i = 0; i < 5; i++) {
          String itemId = 'Item $i';
          itemMap[itemId] =
              new RTreeDatum<String>(new Rectangle(0, i, 1, 1), itemId);
          tree.insert(itemMap[itemId]);
        }

        var items = tree.search(new Rectangle(0, 2, 1, 1));
        expect(items.length, equals(1));
        expect(items.contains(itemMap['Item 2']), equals(true));

        items = tree.search(new Rectangle(0, 1, 1, 2));
        expect(items.length, equals(2));
        expect(items.contains(itemMap['Item 1']), equals(true));
        expect(items.contains(itemMap['Item 2']), equals(true));

        items = tree.search(new Rectangle(0, 0, 1, 5));
        expect(items.length, equals(5));
        expect(items.contains(itemMap['Item 0']), equals(true));
        expect(items.contains(itemMap['Item 1']), equals(true));
        expect(items.contains(itemMap['Item 2']), equals(true));
        expect(items.contains(itemMap['Item 3']), equals(true));
        expect(items.contains(itemMap['Item 4']), equals(true));
      });

      test('insert large amount of items', () {
        RTree tree = new RTree(16);

        for (int i = 0; i < 50; i++) {
          for (int j = 0; j < 50; j++) {
            RTreeDatum<String> item =
                new RTreeDatum<String>(new Rectangle(i, j, 1, 1), 'Item $i:$j');
            tree.insert(item);
          }
        }

        var items = tree.search(new Rectangle(31, 27, 1, 1));
        expect(items.length, equals(1));
        expect(items.elementAt(0).value, equals('Item 31:27'));

        items = tree.search(new Rectangle(0, 0, 2, 50));
        expect(items.length, equals(100));
      });
    });

    group('Remove', () {
      test('remove should only remove first occurance of item', () {
        RTree tree = new RTree(3);
        RTreeDatum<String> item =
            new RTreeDatum<String>(new Rectangle(0, 0, 1, 1), 'Item 1');

        tree.insert(item);
        tree.insert(item);

        var items = tree.search(item.rect);
        expect(items.length, equals(2));

        tree.remove(item);
        items = tree.search(item.rect);
        expect(items.length, equals(1));

        tree.remove(item);
        items = tree.search(item.rect);
        expect(items.length, equals(0));

        tree.insert(item);
        items = tree.search(item.rect);
        expect(items.length, equals(1));
      });

      test('remove from large tree', () {
        RTree tree = new RTree(16);
        Map itemMap = new Map();

        for (int i = 0; i < 50; i++) {
          for (int j = 0; j < 50; j++) {
            String itemId = 'Item $i:$j';
            itemMap[itemId] =
                new RTreeDatum<String>(new Rectangle(i, j, 1, 1), itemId);
            tree.insert(itemMap[itemId]);
          }
        }

        var items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 0:0']);

        items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(0));

        items = tree.search(itemMap['Item 13:41'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 13:41']);

        items = tree.search(itemMap['Item 13:41'].rect);
        expect(items.length, equals(0));
      });

      test('remove all items from tree', () {
        RTree tree = new RTree(12);
        List<RTreeDatum> data = [];

        for (int i = 0; i < 50; i++) {
          for (int j = 0; j < 50; j++) {
            RTreeDatum item =
                new RTreeDatum<String>(new Rectangle(i, j, 1, 1), 'Item $i:$j');
            data.add(item);
            tree.insert(item);
          }
        }

        var items = tree.search(new Rectangle(0, 0, 50, 50));
        expect(items.length, equals(2500));

        data.forEach((RTreeDatum item) {
          tree.remove(item);
        });

        items = tree.search(new Rectangle(0, 0, 50, 50));
        expect(items.length, equals(0));

        //test inserting after removal to ensure new root leaf node functions correctly
        tree.insert(new RTreeDatum<String>(
            new Rectangle(0, 0, 1, 1), 'New Initial Item'));

        items = tree.search(new Rectangle(0, 0, 50, 50));

        items.forEach((datum) {
          expect(datum.value, equals('New Initial Item'));
        });
      });
    });
  });
}
