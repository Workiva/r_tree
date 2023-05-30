/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of r_tree;

/// The base definition of an object that exists in an [RTree]
abstract class RTreeContributor {
  Rectangle? get rect;

  // Calculate if otherRect overlaps with the current rectangle
  //
  // This function is a replication of Rectangle.intersects. It differs in that
  // the inequalities are strict and do not allow for equivalences. This means
  // that the two rectangles are not considered overlapping if they share an edge.
  bool overlaps(Rectangle otherRect) {
    return (rect!.left < otherRect.left + otherRect.width &&
        otherRect.left < rect!.left + rect!.width &&
        rect!.top < otherRect.top + otherRect.height &&
        otherRect.top < rect!.top + rect!.height);
  }
}
