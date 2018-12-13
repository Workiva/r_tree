import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:r_tree/r_tree.dart';

final int BRANCH_FACTOR = 16;

main() {
  print('Running benchmark...');
  var collector = new ScoreCollector();
  new InsertBenchmark(collector).report();
  new RemoveBenchmark(collector).report();
  new SearchBenchmark1(collector).report();
  new SearchBenchmark2(collector).report();
  new SearchBenchmark1(collector, iterateAll: true).report();
  new SearchBenchmark2(collector, iterateAll: true).report();

  var output = '\nName\tResult (microseconds)\n';
  collector.collected.forEach((String name, double value) {
    output += '$name\t$value\n';
  });

  print(output);
}

class InsertBenchmark extends RTreeBenchmarkBase {
  InsertBenchmark(ScoreCollector collector) : super("Insert 5k", collector);

  RTree<String> tree;

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

  void teardown() {}
}

class RemoveBenchmark extends RTreeBenchmarkBase {
  RemoveBenchmark(ScoreCollector collector) : super("Remove 5k", collector);

  RTree<String> tree;
  List<List<RTreeDatum>> items = [];

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

  void teardown() {}
}

class SearchBenchmark1 extends RTreeBenchmarkBase {
  final bool iterateAll;
  SearchBenchmark1(ScoreCollector collector, {this.iterateAll: false})
      : super("Search${iterateAll ? '/Iterate' : ''} 5k", collector);

  RTree<String> tree;

  void run() {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 50; j++) {
        var results = tree.search(new Rectangle(i, j, 1, 1));
        if (iterateAll) {
          for (var result in results) {
            // nothing to do here, just iterating over every result once
          }
        }
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

  void teardown() {}
}

class SearchBenchmark2 extends RTreeBenchmarkBase {
  final bool iterateAll;

  SearchBenchmark2(ScoreCollector collector, {this.iterateAll: false})
      : super("Search${iterateAll ? '/Iterate' : ''} 30k", collector);

  RTree<String> tree;

  void run() {
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 50; j++) {
        var results = tree.search(new Rectangle(i, j, 1, 1));
        if (iterateAll) {
          for (var result in results) {
            // nothing to do here, just iterating over every result once
          }
        }
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

  void teardown() {}
}

class RTreeBenchmarkBase extends BenchmarkBase {
  final int iterations;

  RTreeBenchmarkBase(String name, ScoreCollector collector, {this.iterations: 100})
      : super(name, emitter: collector);

  @override
  void exercise() {
    for (int i = 0; i < iterations; i++) {
      run();
    }
  }
}

class ScoreCollector extends ScoreEmitter {
  Map<String, double> collected = {};

  @override
  void emit(String testName, double value) {
    if (collected.containsKey(testName)) {
      throw new StateError('Already collected results for $testName');
    }

    collected[testName] = value;
  }
}
