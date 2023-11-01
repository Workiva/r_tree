import 'dart:math';

import 'package:r_tree/src/r_tree/rect_util.dart';
import 'package:test/test.dart';

main() {
  group('getMinimumBoundingRectangle', () {
    test('no rectangles', () {
      expect(
        getMinimumBoundingRectangle<num>([]),
        isNull,
      );
    });

    test('single rectangle', () {
      expect(
        getMinimumBoundingRectangle([
          Rectangle(1, 2, 3, 4),
        ]),
        equals(
          Rectangle(1, 2, 3, 4),
        ),
      );
    });

    test('multiple rectangles', () {
      expect(
        getMinimumBoundingRectangle([
          Rectangle(0, 0, 5, 5),
          Rectangle(1, 2, 4, 5),
          Rectangle(10, 2, 4, 6),
        ]),
        equals(
          Rectangle(0, 0, 14, 8),
        ),
      );
    });
  });
}
