library r_tree;

import 'dart:math';

import 'package:r_tree/r_tree.dart';
import 'package:r_tree/src/r_tree/rect_util.dart';
import 'package:test/test.dart';

main() {
  group('RTree', () {
    group('Insert/Search', () {
      test('insert 1 item', () {
        RTree tree = RTree(3);
        RTreeDatum<String> item = RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'Item 1');

        tree.insert(item);
        assertTreeValidity(tree);

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
        assertTreeValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(5));

        items.forEach((item) {
          tree.remove(item);
        });
        assertTreeValidity(tree);

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
          assertTreeValidity(tree);

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
          assertTreeValidity(tree);

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
          assertTreeValidity(tree);

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
        assertTreeValidity(tree);

        var items = tree.search(item.rect);
        expect(items.length, equals(2));

        tree.remove(item);
        assertTreeValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(1));

        tree.remove(item);
        assertTreeValidity(tree);

        items = tree.search(item.rect);
        expect(items.length, equals(0));

        tree.insert(item);
        assertTreeValidity(tree);

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
        assertTreeValidity(tree);

        var items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 0:0']);
        assertTreeValidity(tree);

        items = tree.search(itemMap['Item 0:0'].rect);
        expect(items.length, equals(0));

        items = tree.search(itemMap['Item 13:41'].rect);
        expect(items.length, equals(1));

        tree.remove(itemMap['Item 13:41']);
        assertTreeValidity(tree);

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
        assertTreeValidity(tree);

        var items = tree.search(Rectangle(0, 0, 50, 50));
        expect(items.length, equals(2500));

        data.forEach((RTreeDatum item) {
          tree.remove(item);
        });
        assertTreeValidity(tree);

        items = tree.search(Rectangle(0, 0, 50, 50));
        expect(items.length, equals(0));

        //test inserting after removal to ensure new root leaf node functions correctly
        tree.insert(RTreeDatum<String>(Rectangle(0, 0, 1, 1), 'New Initial Item'));
        assertTreeValidity(tree);

        items = tree.search(Rectangle(0, 0, 50, 50));

        items.forEach((datum) {
          expect(datum.value, equals('New Initial Item'));
        });
      });

      test('remove all items and then reload', () {
        final tree = RTree(3);

        var items = <RTreeDatum<String>>[];
        for (var i = 0; i < 20; i++) {
          final item = RTreeDatum(Rectangle(0, i, 1, 1), 'Item $i');
          items.add(item);
          tree.insert(item);
        }
        assertTreeValidity(tree);

        var searchResult = tree.search(Rectangle(0, 0, 1, 20));
        expect(searchResult, hasLength(20));

        for (final item in items) {
          tree.remove(item);
        }
        assertTreeValidity(tree);

        searchResult = tree.search(Rectangle(0, 0, 1, 20));
        expect(searchResult, isEmpty);

        tree.load(items.sublist(0, 3));
        assertTreeValidity(tree);

        searchResult = tree.search(Rectangle(0, 0, 1, 20));
        expect(searchResult, hasLength(3));
      });
    });
  });
}

/// Comprehensively assert the consistency of the specified tree, including node height, parent references, and bounding
/// rectangles.
void assertTreeValidity<E>(RTree<E> tree) {
  try {
    assertNodeValidity(tree, tree.currentRootNode);
  } on StateError catch (e) {
    fail('${e.message}\nTree:\n${stringifyTree(tree)}');
  }
}

/// Comprehensively assert the consistency of the specified subtree, including node height, parent references, and
/// bounding rectangles.
_SubtreeValidationData assertNodeValidity<E>(RTree<E> tree, RTreeContributor contributor) {
  if (contributor is LeafNode<E>) {
    return assertLeafNodeValidity(tree, contributor);
  } else if (contributor is NonLeafNode<E>) {
    return assertNonLeafNodeValidity(tree, contributor);
  }

  // This is a datum
  return _SubtreeValidationData(0, contributor.rect);
}

/// Comprehensively assert the consistency of the subtree rooted at the specified leaf node, including node height,
/// parent references, and bounding rectangles.
_SubtreeValidationData assertLeafNodeValidity<E>(RTree<E> tree, LeafNode<E> node) {
  if (node.height != 1) {
    throw StateError('Leaf height of ${node.height} should be 1.');
  }

  final actualRect = getMinimumBoundingRectangle(
        node.children.map((child) => child.rect),
      ) ??
      const Rectangle<num>(0, 0, 0, 0);

  // Assert this node's rect/bounds match its actual structure
  if (node.rect != actualRect) {
    throw StateError('Leaf rect ${node.rect} should be $actualRect.');
  }

  return _SubtreeValidationData(1, actualRect);
}

/// Comprehensively assert the consistency of the subtree rooted at the specified non-leaf node, including node height,
/// parent references, and bounding rectangles.
_SubtreeValidationData assertNonLeafNodeValidity<E>(RTree<E> tree, NonLeafNode<E> node) {
  // Assert parent references for children point back to this node
  node.children.forEach((child) {
    if (child.parent != node) {
      throw StateError("Non-leaf child's parent reference is incorrect.");
    }
  });

  // Traverse the tree from this child and collect validation data to propagate upwards
  final childrenValidationData = node.children.map((child) => assertNodeValidity(tree, child)).toList();

  // Recalculate the actual bounding rectangle for this subtree using validation data
  final childrenRects = childrenValidationData.map((childValidationData) => childValidationData.rect);
  final actualRect = getMinimumBoundingRectangle(childrenRects) ?? const Rectangle<num>(0, 0, 0, 0);

  // Recalculate the actual height for this subtree using validation data
  final compareMaxWithChild = (int maxHeight, _SubtreeValidationData child) => max(maxHeight, child.height);
  final maxChildHeight = childrenValidationData.fold(0, compareMaxWithChild);

  // Assert this node's height matches its actual structure
  final actualNodeHeight = 1 + maxChildHeight;
  if (node.height != actualNodeHeight) {
    throw StateError('Non-leaf height of ${node.height} should be $actualNodeHeight.');
  }

  // Assert this node's rect/bounds match its actual structure
  if (node.rect != actualRect) {
    throw StateError('Non-leaf rect of ${node.rect} should be $actualRect.');
  }

  return _SubtreeValidationData(actualNodeHeight, actualRect);
}

/// Values computed for some subtree to be used for asserting rollup-field accuracy.
class _SubtreeValidationData {
  final int height;
  final Rectangle<num> rect;
  _SubtreeValidationData(this.height, this.rect);
}

/// Serializes the tree in a human-readable form for debugging.
String stringifyTree<E>(RTree<E> tree) {
  final buffer = StringBuffer();
  stringifyNode(buffer, tree.currentRootNode, 0);
  return buffer.toString();
}

/// Serializes the subtree from [contributor] in a humnan-readable form for debugging.
void stringifyNode<E>(StringBuffer buffer, RTreeContributor contributor, int level) {
  buffer.write('${' ' * level}${contributor.runtimeType}');
  if (contributor is Node<E>) {
    buffer.write('(height=${contributor.height}, rect=${contributor.rect}):\n');
    for (final child in contributor.children) {
      stringifyNode(buffer, child, level + 1);
    }
  } else if (contributor is RTreeDatum<E>) {
    buffer.write('(rect=${contributor.rect}): ${contributor.value}\n');
  }
}

class _InsertCase {
  final Function(RTree tree, Iterable<RTreeDatum<String>> toAdd) method;
  final String name;

  _InsertCase(this.name, this.method);
}
