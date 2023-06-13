import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:r_tree/r_tree.dart';

final int BRANCH_FACTOR = 16;

main() {
  print('Running benchmark...');
  var collector = ScoreCollector();
  InsertBenchmark(collector).report();
  LoadBenchmark(collector).report();
  RemoveBenchmark(collector).report();
  SearchBenchmark1(collector).report();
  SearchBenchmark1(collector, iterateAll: true).report();
  SearchBenchmark1(collector, iterateAll: true, useLoad: true).report();
  SearchBenchmark2(collector).report();
  SearchBenchmark2(collector, iterateAll: true).report();
  SearchBenchmark2(collector, iterateAll: true, useLoad: true).report();

  var longestName = collector.collected.keys
      .reduce(
          (value, element) => value.length > element.length ? value : element)
      .length;
  var longestValue = collector.collected.values
      .reduce((value, element) =>
          value.toStringAsFixed(2).length > element.toStringAsFixed(2).length
              ? value
              : element)
      .toStringAsFixed(2);
  var nameHeading = 'Name';
  var heading =
      '$nameHeading${' ' * (longestName - nameHeading.length)}\tResult (microseconds)';
  var separator = '-' * (heading.length + 5);
  var output = '\n$heading\n$separator\n';
  collector.collected.forEach((String name, double value) {
    name += (' ' * (longestName - name.length));
    var valueString = value.toStringAsFixed(2);
    output +=
        '$name\t${' ' * (longestValue.length - valueString.length)}${valueString}\n';
  });

  print(output);
}

class InsertBenchmark extends RTreeBenchmarkBase {
  InsertBenchmark(ScoreCollector collector) : super("Insert 5k", collector);

  RTree<String> tree;
  List<RTreeDatum<String>> datum;

  void run() {
    tree = RTree<String>(BRANCH_FACTOR);
    for (var data in datum) {
      tree.insert(data);
    }
  }

  void setup() {
    Random rand = Random();
    datum = <RTreeDatum<String>>[];
    for (int i = 0; i < 5000; i++) {
      int x = rand.nextInt(100000);
      int y = rand.nextInt(100000);
      int height = rand.nextInt(100);
      int width = rand.nextInt(100);
      RTreeDatum item =
          RTreeDatum<String>(Rectangle(x, y, width, height), 'item $i');
      datum.add(item);
    }
  }

  void teardown() {}
}

class LoadBenchmark extends RTreeBenchmarkBase {
  LoadBenchmark(ScoreCollector collector) : super("Load 5k ", collector);

  RTree<String> tree;
  List<RTreeDatum<String>> datum;

  void run() {
    tree = RTree<String>(BRANCH_FACTOR);
    tree.load(datum);
  }

  void setup() {
    Random rand = Random();
    datum = <RTreeDatum<String>>[];
    for (int i = 0; i < 5000; i++) {
      int x = rand.nextInt(100000);
      int y = rand.nextInt(100000);
      int height = rand.nextInt(100);
      int width = rand.nextInt(100);
      RTreeDatum item =
          RTreeDatum<String>(Rectangle(x, y, width, height), 'item $i');
      datum.add(item);
    }
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
    tree = RTree<String>(BRANCH_FACTOR);

    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        if (items.length <= i) {
          items.add([]);
        }

        Rectangle rect = Rectangle(i, j, 1, 1);
        final datum = RTreeDatum<String>(rect, 'item $i:$j');
        items[i].add(datum);
        tree.insert(datum);
      }
    }
  }

  void teardown() {}
}

class SearchBenchmark1 extends RTreeBenchmarkBase {
  /// Allows comparing search performance if the results are iterated or not.
  final bool iterateAll;

  /// Allows comparing search performance between trees built out via insert or load
  final bool useLoad;

  SearchBenchmark1(ScoreCollector collector,
      {this.iterateAll = false, this.useLoad = false})
      : super(
            "Search${iterateAll ? '/Iterate' : ''} ${useLoad ? 'using Load' : ''} 5k",
            collector);

  RTree<String> tree;

  void run() {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 50; j++) {
        var results = tree.search(Rectangle(i, j, 1, 1));
        if (iterateAll) {
          // ignore: unused_local_variable
          for (var result in results) {
            // nothing to do here, just iterating over every result once
          }
        }
      }
    }
  }

  void setup() {
    tree = RTree(BRANCH_FACTOR);

    var datum = <RTreeDatum<String>>[];
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 50; j++) {
        Rectangle rect = Rectangle(i, j, 1, 1);
        datum.add(RTreeDatum<String>(rect, 'item1'));
        datum.add(RTreeDatum<String>(rect, 'item2'));
        datum.add(RTreeDatum<String>(rect, 'item3'));
        datum.add(RTreeDatum<String>(rect, 'item4'));
        datum.add(RTreeDatum<String>(rect, 'item5'));
        datum.add(RTreeDatum<String>(rect, 'item6'));
        datum.add(RTreeDatum<String>(rect, 'item7'));
        datum.add(RTreeDatum<String>(rect, 'item8'));
        datum.add(RTreeDatum<String>(rect, 'item9'));
        datum.add(RTreeDatum<String>(rect, 'item10'));
      }
    }

    if (useLoad) {
      tree.load(datum);
    } else {
      datum.forEach(tree.insert);
    }
  }

  void teardown() {}
}

class SearchBenchmark2 extends RTreeBenchmarkBase {
  /// Allows comparing search performance if the results are iterated or not.
  final bool iterateAll;

  /// Allows comparing search performance between trees built out via insert or load
  final bool useLoad;

  SearchBenchmark2(ScoreCollector collector,
      {this.iterateAll = false, this.useLoad = false})
      : super(
            "Search${iterateAll ? '/Iterate' : ''} ${useLoad ? 'using Load' : ''} 30k",
            collector);

  RTree<String> tree;

  void run() {
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 50; j++) {
        var results = tree.search(Rectangle(i, j, 1, 1));
        if (iterateAll) {
          // ignore: unused_local_variable
          for (var result in results) {
            // nothing to do here, just iterating over every result once
          }
        }
      }
    }
  }

  void setup() {
    tree = RTree<String>(BRANCH_FACTOR);

    var datum = <RTreeDatum<String>>[];
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        Rectangle rect = Rectangle(i, j, 1, 1);
        datum.add(RTreeDatum<String>(rect, 'item1 $i:$j'));
        datum.add(RTreeDatum<String>(rect, 'item2 $i:$j'));
        datum.add(RTreeDatum<String>(rect, 'item3 $i:$j'));
      }
    }

    if (useLoad) {
      tree.load(datum);
    } else {
      datum.forEach(tree.insert);
    }
  }

  void teardown() {}
}

class RTreeBenchmarkBase extends BenchmarkBase {
  final int iterations;

  RTreeBenchmarkBase(String name, ScoreCollector collector,
      {this.iterations = 100})
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
      throw StateError('Already collected results for $testName');
    }

    collected[testName] = value;
  }
}
