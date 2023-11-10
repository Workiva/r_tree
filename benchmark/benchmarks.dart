import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:r_tree/r_tree.dart';

const int branchFactor = 16;
const int randomSeed = 3;
void main() {
  print('Running benchmarks...');
  final collector = ScoreCollector();
  InsertBenchmark(collector, totalItems: 100).report();
  InsertBenchmark(collector, totalItems: 1000).report();
  InsertBenchmark(collector, totalItems: 10000).report();

  LoadBenchmark(collector, totalItems: 100).report();
  LoadBenchmark(collector, totalItems: 1000).report();
  LoadBenchmark(collector, totalItems: 10000).report();

  RemoveBenchmark(collector).report();

  SearchBenchmark(collector, totalItems: 100, iterateAll: true).report();
  SearchBenchmark(collector, totalItems: 1000, iterateAll: true).report();
  SearchBenchmark(collector, totalItems: 10000, iterateAll: true).report();

  SearchBenchmark(collector, totalItems: 100, iterateAll: true, useLoad: true).report();
  SearchBenchmark(collector, totalItems: 1000, iterateAll: true, useLoad: true).report();
  SearchBenchmark(collector, totalItems: 10000, iterateAll: true, useLoad: true).report();

  final longestName =
      collector.collected.keys.reduce((value, element) => value.length > element.length ? value : element).length;
  final longestValue = collector.collected.values
      .reduce((value, element) => value.toStringAsFixed(2).length > element.toStringAsFixed(2).length ? value : element)
      .toStringAsFixed(2);
  const nameHeading = 'Name';
  final heading = '$nameHeading${' ' * (longestName - nameHeading.length)}\tResult (microseconds)';
  final separator = '-' * (heading.length + 5);
  var output = '\n$heading\n$separator\n';
  collector.collected.forEach((name, value) {
    name += ' ' * (longestName - name.length);
    final valueString = value.toStringAsFixed(2);
    output += '$name\t${' ' * (longestValue.length - valueString.length)}$valueString\n';
  });

  print(output);
}

class InsertBenchmark extends RTreeBenchmarkBase {
  final int totalItems;

  InsertBenchmark(ScoreCollector collector, {this.totalItems = 500}) : super('Insert $totalItems', collector);

  late RTree<String> tree;
  late List<RTreeDatum<String>> datum;

  @override
  void run() {
    tree = RTree<String>(branchFactor);
    for (final data in datum) {
      tree.insert(data);
    }
  }

  @override
  void setup() {
    final rand = Random(randomSeed);
    datum = <RTreeDatum<String>>[];
    for (var i = 0; i < totalItems; i++) {
      final x = rand.nextInt(1000);
      final y = rand.nextInt(1000);
      final height = rand.nextInt(100);
      final width = rand.nextInt(100);
      final item = RTreeDatum<String>(Rectangle(x, y, width, height), 'item $i');
      datum.add(item);
    }
  }

  @override
  void teardown() {}
}

class LoadBenchmark extends RTreeBenchmarkBase {
  final int totalItems;

  LoadBenchmark(ScoreCollector collector, {required this.totalItems}) : super('Load $totalItems ', collector);

  late RTree<String> tree;
  late List<RTreeDatum<String>> datum;

  @override
  void run() {
    tree = RTree<String>(branchFactor);
    tree.load(datum);
  }

  @override
  void setup() {
    final rand = Random(randomSeed);
    datum = <RTreeDatum<String>>[];
    for (var i = 0; i < totalItems; i++) {
      final x = rand.nextInt(1000);
      final y = rand.nextInt(1000);
      final height = rand.nextInt(100);
      final width = rand.nextInt(100);
      final item = RTreeDatum<String>(Rectangle(x, y, width, height), 'item $i');
      datum.add(item);
    }
    datum.shuffle();
  }

  @override
  void teardown() {}
}

class RemoveBenchmark extends RTreeBenchmarkBase {
  RemoveBenchmark(ScoreCollector collector) : super('Remove 5k', collector);

  late RTree<String> tree;
  final items = <List<RTreeDatum<String>>>[];

  @override
  void run() {
    for (var i = 0; i < 100; i++) {
      for (var j = 0; j < 50; j++) {
        tree.remove(items[i][j]);
      }
    }
  }

  @override
  void setup() {
    tree = RTree<String>(branchFactor);

    for (var i = 0; i < 100; i++) {
      for (var j = 0; j < 100; j++) {
        if (items.length <= i) {
          items.add([]);
        }

        final rect = Rectangle(i, j, 1, 1);
        final datum = RTreeDatum<String>(rect, 'item $i:$j');
        items[i].add(datum);
        tree.insert(datum);
      }
    }
  }

  @override
  void teardown() {}
}

class SearchBenchmark extends RTreeBenchmarkBase {
  final int totalItems;

  /// Allows comparing search performance if the results are iterated or not.
  final bool iterateAll;

  /// Allows comparing search performance between trees built out via insert or load
  final bool useLoad;

  SearchBenchmark(
    ScoreCollector collector, {
    required this.totalItems,
    this.iterateAll = false,
    this.useLoad = false,
  }) : super("Search${iterateAll ? '/Iterate' : ''} ${useLoad ? '(using Load)' : '(using Insert)'} $totalItems",
            collector);

  late RTree<String> tree;
  late int size;

  @override
  void run() {
    for (var x = 0; x < size; x++) {
      for (var y = 0; y < size; y++) {
        final results = tree.search(Rectangle(x, y, 1, 1));
        if (iterateAll) {
          // ignore: unused_local_variable
          for (final result in results) {
            // nothing to do here, just iterating over every result once
          }
        }
      }
    }
  }

  @override
  void setup() {
    size = sqrt(totalItems).ceil();
    tree = RTree(branchFactor);

    final datum = <RTreeDatum<String>>[];
    for (var i = 0; i < 10; i++) {
      for (var j = 0; j < 50; j++) {
        final rect = Rectangle(i, j, 1, 1);
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

  @override
  void teardown() {}
}

class RTreeBenchmarkBase extends BenchmarkBase {
  final int iterations;

  RTreeBenchmarkBase(String name, ScoreCollector collector, {this.iterations = 100}) : super(name, emitter: collector);

  @override
  void exercise() {
    for (var i = 0; i < iterations; i++) {
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
