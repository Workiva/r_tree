import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

import '../lib/r_tree.dart';

final int BRANCH_FACTOR = 16;

main() {
  RTreeBenchmark.main();
}

class RTreeBenchmark {
  static void main() {
    InsertBenchmark.main();
    RemoveBenchmark.main();
    SearchBenchmark1.main();
    SearchBenchmark2.main();
  }
}

class InsertBenchmark extends BenchmarkBase {
  InsertBenchmark() : super("Insert 5000 items with random rectangles.");

  RTree<String> tree;

  static void main() {
    new InsertBenchmark().report();
  }

  void run() {
    Random rand = new Random();
    for (int i = 0; i < 5000; i++) {
      int x = rand.nextInt(100000);
      int y = rand.nextInt(100000);
      int height = rand.nextInt(100);
      int width = rand.nextInt(100);
      RTreeDatum item = new RTreeDatum(new Rectangle(x, y, width, height), 'item $i');
      tree.insert(item);
    }
  }

  void setup() {
    tree = new RTree<String>(BRANCH_FACTOR);
  }

  void teardown() {
  }
}

class RemoveBenchmark extends BenchmarkBase {
  RemoveBenchmark() : super("Remove 5000 items from a tree of 10000 items.");

  RTree<String> tree;
  List<List<RTreeDatum>> items = [];

  static void main() {
    new RemoveBenchmark().report();
  }

  void run() {
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 50; j++) {
        tree.remove(items[i][j]);
      }
    }
  }

  void setup() {
    tree = new RTree<String>(BRANCH_FACTOR);

    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        if (items.length <= i) {
          items.add([]);
        }
        
        Rectangle rect = new Rectangle(i, j, 1, 1);
        items[i].add(new RTreeDatum<String>(rect, 'item $i:$j'));
      }
    }
  }

  void teardown() {
  }
}

class SearchBenchmark1 extends BenchmarkBase {
  SearchBenchmark1() : super("Search 5000 items. (500 rectangles, 10 items each) Find all 10 items for each of the 500 rectangles.");

  RTree<String> tree;

  static void main() {
    new SearchBenchmark1().report();
  }

  void run() {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 50; j++) {
        tree.search(new Rectangle(i, j, 1, 1));
      }
    }
  }

  void setup() {
    tree = new RTree(BRANCH_FACTOR);

    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 50; j++) {
        Rectangle rect = new Rectangle(i, j, 1, 1);
        tree.insert(new RTreeDatum<String>(rect, 'item1'));
        tree.insert(new RTreeDatum<String>(rect, 'item2'));
        tree.insert(new RTreeDatum<String>(rect, 'item3'));
        tree.insert(new RTreeDatum<String>(rect, 'item4'));
        tree.insert(new RTreeDatum<String>(rect, 'item5'));
        tree.insert(new RTreeDatum<String>(rect, 'item6'));
        tree.insert(new RTreeDatum<String>(rect, 'item7'));
        tree.insert(new RTreeDatum<String>(rect, 'item8'));
        tree.insert(new RTreeDatum<String>(rect, 'item9'));
        tree.insert(new RTreeDatum<String>(rect, 'item10'));
      }
    }
  }

  void teardown() {
  }
}

class SearchBenchmark2 extends BenchmarkBase {
  SearchBenchmark2() : super("Search 30000 items. (10000 rectangles. 3 items each) Find all 3 items for 5000 of the rectangles.");

  RTree<String> tree;
  
  static void main() {
    new SearchBenchmark2().report();
  }

  void run() {
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 50; j++) {
        tree.search(new Rectangle(i, j, 1, 1));
      }
    }
  }

  void setup() {
    tree = new RTree<String>(BRANCH_FACTOR);

    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        Rectangle rect = new Rectangle(i, j, 1, 1);
        tree.insert(new RTreeDatum<String>(rect, 'item1 $i:$j'));
        tree.insert(new RTreeDatum<String>(rect, 'item2 $i:$j'));
        tree.insert(new RTreeDatum<String>(rect, 'item3 $i:$j'));
      }
    }
  }

  void teardown() {
  }
}