# RTree [![Build Status](https://travis-ci.org/Workiva/r_tree.svg)](https://travis-ci.org/Workiva/r_tree)

A recursive RTree library written in Dart. This R-tree implementation is used to index and query two-dimensional data. Items are inserted and balanced via the RTree class and can then be queried by Rectangle.  The balancing can be tweaked by modifying the branch factor of the RTree.

> "R-trees are tree data structures used for spatial access methods, i.e., for indexing multi-dimensional information such as geographical coordinates, rectangles or polygons." - http://en.wikipedia.org/wiki/R-tree

## Example

Run the example app for a visual demonstration of the RTree
```
pub serve example
```
Navigate to `http://localhost:8080`.  A canvas is drawn, click & drag on the canvas to add rectangles of various colors to your RTree, then click the search button and click & drag over an area of the canvas to search it for rectangles.

## Benchmarks

Run the benchmarks in the command line (Dart VM) using:
```
dart benchmark/benchmarks.dart
```

You can also run them in a browser using dart2js using `pub serve benchmark` or `pub build benchmark` and then serving them with your http server of choice.  Click the run button and observe the output in the browser console.
