library r_tree;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:test/test.dart';

main() {
  group('RTree', () {
    group('Insert/Search', () {
      test('insert 1 item', () {
        RTree tree = RTree(3);
        RTreeDatum<String> item = RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 1');

        tree.insert(item);
        assertTreeHeightValidity(tree);

        var items = tree.search(item.rect, shouldInclude: (_) => false);
        expect(items, isEmpty);

        items = tree.search(item.rect);
        expect(items.length, equals(1));
        expect(items.elementAt(0).value, equals('Item 1'));

        items.forEach((item) {
          tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 2'));
          tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 3'));
          tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 4'));
          tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 5'));
        });
        assertTreeHeightValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(5));

        items.forEach((item) {
          tree.remove(item);
        });
        assertTreeHeightValidity(tree);

        items = tree.search((item.rect));
        expect(items.isEmpty, isTrue);
      });

      final addMethods = [
        _InsertCase('insert', (RTree tree, Iterable<RTreeDatum<String>> toAdd) {
          toAdd.forEach(tree.insert);
        }),
        _InsertCase('load', (RTree tree, Iterable<RTreeDatum<String>> toAdd) {
          tree.load(toAdd.toList());
        })
      ];

      for (final addMethod in addMethods) {
        test('search for 1 cell in large format ranges (${addMethod.name})', () {
          RTree tree = RTree(3);
          Map itemMap = Map();
          List<RTreeDatum<String>> itemsToInsert = [];

          for (int i = 0; i < 10; i++) {
            String itemId = 'Item $i';
            itemMap[itemId] = RTreeDatum<String>(Rectangle(i, 0, 10 - i, 10), itemId);
            itemsToInsert.add(itemMap[itemId]);
          }

          addMethod.method(tree, itemsToInsert);
          assertTreeHeightValidity(tree);

          var items = tree.search(Rectangle(0, 0, 1, 3)); // A1:A3
          expect(items.length, equals(1));
          expect(items.contains(itemMap['Item 0']), equals(true));

          items = tree.search(Rectangle(0, 3, 1, 10)); // A3:A13
          expect(items.length, equals(1));
          expect(items.contains(itemMap['Item 0']), equals(true));

          items = tree.search(Rectangle(4, 4, 1, 1)); // E5
          expect(items.length, equals(5));
          expect(items.contains(itemMap['Item 0']), equals(true));
          expect(items.contains(itemMap['Item 1']), equals(true));
          expect(items.contains(itemMap['Item 2']), equals(true));
          expect(items.contains(itemMap['Item 3']), equals(true));
          expect(items.contains(itemMap['Item 4']), equals(true));
        });

        test('insert enough items to cause split (${addMethod.name})', () {
          RTree tree = RTree(3);
          Map itemMap = Map();
          List<RTreeDatum<String>> itemsToInsert = [];

          for (int i = 0; i < 5; i++) {
            String itemId = 'Item $i';
            itemMap[itemId] = RTreeDatum<String>(Rectangle(0, i, 1, 1), itemId);
            itemsToInsert.add(itemMap[itemId]);
          }

          addMethod.method(tree, itemsToInsert);
          assertTreeHeightValidity(tree);

          var items = tree.search(Rectangle(0, 2, 1, 1));
          expect(items.length, equals(1));
          expect(items.contains(itemMap['Item 2']), equals(true));

          items = tree.search(Rectangle(0, 1, 1, 2));
          expect(items.length, equals(2));
          expect(items.contains(itemMap['Item 1']), equals(true));
          expect(items.contains(itemMap['Item 2']), equals(true));

          items = tree.search(Rectangle(0, 0, 1, 5));
          expect(items.length, equals(5));
          expect(items.contains(itemMap['Item 0']), equals(true));
          expect(items.contains(itemMap['Item 1']), equals(true));
          expect(items.contains(itemMap['Item 2']), equals(true));
          expect(items.contains(itemMap['Item 3']), equals(true));
          expect(items.contains(itemMap['Item 4']), equals(true));
        });

        test('insert large amount of items (${addMethod.name})', () {
          RTree tree = RTree(16);
          List<RTreeDatum<String>> itemsToInsert = [];

          for (int i = 0; i < 50; i++) {
            for (int j = 0; j < 50; j++) {
              RTreeDatum<String> item = RTreeDatum<String>(Rectangle(i, j, 1, 1), 'Item $i:$j');
              itemsToInsert.add(item);
            }
          }

          addMethod.method(tree, itemsToInsert);
          assertTreeHeightValidity(tree);

          var items = tree.search(Rectangle(31, 27, 1, 1));
          expect(items.length, equals(1));
          expect(items.elementAt(0).value, equals('Item 31:27'));

          items = tree.search(Rectangle(0, 0, 2, 50));
          expect(items.length, equals(100));
        });
      }
    });

    group('Remove', () {
      test('remove should only remove first occurrence of item', () {
        RTree tree = RTree(3);
        RTreeDatum<String> item = RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 1');

        tree.insert(item);
        tree.insert(item);
        assertTreeHeightValidity(tree);

        var items = tree.search(item.rect);
        expect(items.length, equals(2));

        tree.remove(item);
        assertTreeHeightValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(1));

        tree.remove(item);
        assertTreeHeightValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(0));

        tree.insert(item);
        assertTreeHeightValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(1));
      });

      test('remove from large tree', () {
        RTree tree = RTree(16);
        Map itemMap = Map();

        for (int i = 0; i < 50; i++) {
          for (int j = 0; j < 50; j++) {
            String itemId = 'Item $i:$j';
            itemMap[itemId] = RTreeDatum<String>(Rectangle(i, j, 1, 1), itemId);
            tree.insert(itemMap[itemId]);
          }
        }
        assertTreeHeightValidity(tree);

        var items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 0:0']);
        assertTreeHeightValidity(tree);

        items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(0));

        items = tree.search(itemMap['Item 13:41'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 13:41']);
        assertTreeHeightValidity(tree);

        items = tree.search(itemMap['Item 13:41'].rect);
        expect(items.length, equals(0));
      });

      test('remove all items from tree', () {
        RTree tree = RTree(12);
        List<RTreeDatum> data = [];

        for (int i = 0; i < 50; i++) {
          for (int j = 0; j < 50; j++) {
            RTreeDatum item = RTreeDatum<String>(Rectangle(i, j, 1, 1), 'Item $i:$j');
            data.add(item);
            tree.insert(item);
          }
        }
        assertTreeHeightValidity(tree);

        var items = tree.search(Rectangle(0, 0, 50, 50));
        expect(items.length, equals(2500));

        data.forEach((RTreeDatum item) {
          tree.remove(item);
        });
        assertTreeHeightValidity(tree);

        items = tree.search(Rectangle(0, 0, 50, 50));
        expect(items.length, equals(0));

        //test inserting after removal to ensure new root leaf node functions correctly
        tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'New Initial Item'));
        assertTreeHeightValidity(tree);

        items = tree.search(Rectangle(0, 0, 50, 50));

        items.forEach((datum) {
          expect(datum.value, equals('New Initial Item'));
        });
      });

      test('remove all items and then reload', () {
        final tree = RTree(3);

        final items = <RTreeDatum<String>>[];
        for (var i = 0; i < 20; i++) {
          final item = RTreeDatum(Rectangle(0, i, 1, 1), 'Item $i');
          items.add(item);
          tree.insert(item);
        }

        for (final item in items) {
          tree.remove(item);
        }

        tree.load(items.sublist(0, 3));
      });
    });
  });
}

void assertTreeHeightValidity<E>(RTree<E> tree) {
  try {
    assertNodeHeightValidity(tree, tree.currentRootNode);
  } on StateError catch (e) {
    fail('${e.message}\nTree:\n${stringifyTree(tree)}');
  }
}

int assertNodeHeightValidity<E>(RTree<E> tree, RTreeContributor contributor) {
  if (contributor is LeafNode<E>) {
    if (contributor.height != 1) {
      throw StateError('Leaf height of ${contributor.height} should be 1.');
    }

    return 1;
  } else if (contributor is NonLeafNode<E>) {
    var maxChildHeight = 0;
    if (contributor.children.isNotEmpty) {
      for (final child in contributor.children) {
        final childHeight = assertNodeHeightValidity(tree, child);
        if (childHeight > maxChildHeight) {
          maxChildHeight = childHeight;
        }
      }
    }

    final actualNodeHeight = 1 + maxChildHeight;
    if (contributor.height != actualNodeHeight) {
      throw StateError('Non-leaf height of ${contributor.height} should be $actualNodeHeight.');
    }

    return actualNodeHeight;
  }

  return 0;
}

String stringifyTree<E>(RTree<E> tree) {
  final buffer = StringBuffer();
  stringifyNode(buffer, tree.currentRootNode, 0);
  return buffer.toString();
}

void stringifyNode<E>(StringBuffer buffer, RTreeContributor contributor, int level) {
  buffer.write('${' ' * level}${contributor.runtimeType}');
  if (contributor is Node<E>) {
    buffer.write('(height=${contributor.height}):\n');
    for (final child in contributor.children) {
      stringifyNode(buffer, child, level + 1);
    }
  } else if (contributor is RTreeDatum<E>) {
    buffer.write(': ${contributor.value}\n');
  }
}

class _InsertCase {
  final Function(RTree tree, Iterable<RTreeDatum<String>> toAdd) method;
  final String name;

  _InsertCase(this.name, this.method);
}
