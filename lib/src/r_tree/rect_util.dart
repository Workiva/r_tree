import 'dart:math';

/// Compute the minimum bounding rectangles of the specified rectangles. Returns null if no rectangles provided.
Rectangle<E>? getMinimumBoundingRectangle<E extends num>(Iterable<Rectangle<E>> rectangles) {
  if (rectangles.isEmpty) {
    return null;
  }

  var minimumBoundingRectangle = rectangles.first;
  for (final rectangle in rectangles) {
    minimumBoundingRectangle = minimumBoundingRectangle.boundingBox(rectangle);
  }

  return minimumBoundingRectangle;
}
