import 'dart:math';

extension RectangleHelper on Rectangle {
  /// Calculate if otherRect overlaps with the current rectangle
  ///
  /// This function is a replication of Rectangle.intersects. It differs in that
  /// the inequalities are strict and do not allow for equivalences. This means
  /// that the two rectangles are not considered overlapping if they share an edge.
  bool overlaps(Rectangle otherRect) {
    return left < otherRect.left + otherRect.width &&
        otherRect.left < left + width &&
        top < otherRect.top + otherRect.height &&
        otherRect.top < top + height;
  }

  num area() => width * height;
}
