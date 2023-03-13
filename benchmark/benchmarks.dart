import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:rbush/rbush.dart';

import 'package:r_tree/r_tree.dart';

final int BRANCH_FACTOR = 16;

main() {
  print('Running benchmark...');
  var collector = ScoreCollector();
  InsertBenchmark(collector).report();
  RBushInsertBenchmark(collector).report();
  RBushLoadBenchmark(collector).report();

  RemoveBenchmark(collector).report();
  RBushRemoveBenchmark(collector).report();

  SearchBenchmark(collector, X: 10, Y: 50, Z: 10).report();
  RBushSearchBenchmark(collector, X: 10, Y: 50, Z: 10).report();
  ListSearchBenchmark(collector, X: 10, Y: 50, Z: 10).report();

  SearchBenchmark(collector, X: 100, Y: 100, Z: 3).report();
  RBushSearchBenchmark(collector, X: 100, Y: 100, Z: 3).report();

  var output = '\nName\tResult (microseconds)\n';
  collector.collected.forEach((String name, double value) {
    output += '$name\t$value\n';
  });

  print(output);
}

class ListSearchBenchmark extends RTreeBenchmarkBase {
  final bool iterateAll;
  final int X;
  final int Y;
  final int Z;
  List<RTreeDatum<String>> list = [];

  ListSearchBenchmark(
    ScoreCollector collector, {
    this.X,
    this.Y,
    this.Z,
    this.iterateAll = false,
  }) : super(
            "List Search ${iterateAll ? '/Iterate' : ''} ${X * Y * Z ~/ 1000}k",
            collector);

  List<String> search(Rectangle rectangle) {
    final result = <String>[];
    for (final entry in list) {
      if (entry.rect.intersects(rectangle)) {
        result.add(entry.value);
      }
    }
    return result;
  }

  void run() {
    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
        var results = search(Rectangle(i, j, 1, 1));
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
    list = [];

    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
        Rectangle rect = Rectangle(i, j, 1, 1);

        for (int k = 0; k < Z; k++) {
          list.add(RTreeDatum<String>(rect, 'item$k'));
        }
      }
    }
  }

  void teardown() {}
}

class RBushSearchBenchmark extends RTreeBenchmarkBase {
  final bool iterateAll;
  final int X;
  final int Y;
  final int Z;
  var rbush = RBush<String>(BRANCH_FACTOR);

  RBushSearchBenchmark(
    ScoreCollector collector, {
    this.X,
    this.Y,
    this.Z,
    this.iterateAll = false,
  }) : super(
            "RBush Search ${iterateAll ? '/Iterate' : ''} ${X * Y * Z ~/ 1000}k",
            collector);

  void run() {
    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
        final id = i.toDouble();
        final jd = j.toDouble();

        var results = rbush
            .search(RBushBox(minX: id, maxX: id + 1, minY: jd, maxY: jd + 1));
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
    rbush = RBush<String>(BRANCH_FACTOR);

    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
        final id = i.toDouble();
        final jd = j.toDouble();

        for (int k = 0; k < Z; k++) {
          rbush.insert(RBushElement<String>(
              minX: id, maxX: id + 1, maxY: jd, minY: jd - 1, data: 'item$k'));
        }
      }
    }
  }

  void teardown() {}
}

class InsertBenchmark extends RTreeBenchmarkBase {
  InsertBenchmark(ScoreCollector collector) : super("Insert 5k", collector);

  RTree<String> tree;

  void run() {
    Random rand = Random();
    for (int i = 0; i < 5000; i++) {
      int x = rand.nextInt(100000);
      int y = rand.nextInt(100000);
      int height = rand.nextInt(100);
      int width = rand.nextInt(100);
      RTreeDatum item =
          RTreeDatum<String>(Rectangle(x, y, width, height), 'item $i');
      tree.insert(item);
    }
  }

  void setup() {
    tree = RTree<String>(BRANCH_FACTOR);
  }

  void teardown() {}
}

class RBushInsertBenchmark extends RTreeBenchmarkBase {
  RBushInsertBenchmark(ScoreCollector collector)
      : super("RBush Insert 5k", collector);

  RBush<String> rbush;

  void run() {
    Random rand = Random();
    for (int i = 0; i < 5000; i++) {
      final x = rand.nextInt(100000).toDouble();
      final y = rand.nextInt(100000).toDouble();
      final height = rand.nextInt(100).toDouble();
      final width = rand.nextInt(100).toDouble();

      final item = RBushElement<String>(
          minX: x, maxX: x + width, minY: y, maxY: x + height, data: 'item $i');
      rbush.insert(item);
    }
  }

  void setup() {
    rbush = RBush<String>(BRANCH_FACTOR);
  }

  void teardown() {}
}

class RBushLoadBenchmark extends RTreeBenchmarkBase {
  RBushLoadBenchmark(ScoreCollector collector)
      : super("RBush Load 5k", collector);

  RBush<String> rbush;

  void run() {
    Random rand = Random();

    final data = List.generate(5000, (i) {
      final x = rand.nextInt(100000).toDouble();
      final y = rand.nextInt(100000).toDouble();
      final height = rand.nextInt(100).toDouble();
      final width = rand.nextInt(100).toDouble();

      return RBushElement<String>(
          minX: x, maxX: x + width, minY: y, maxY: x + height, data: 'item $i');
    }, growable: false);

    rbush.load(data);
  }

  void setup() {
    rbush = RBush<String>(BRANCH_FACTOR);
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

class RBushRemoveBenchmark extends RTreeBenchmarkBase {
  RBushRemoveBenchmark(ScoreCollector collector)
      : super("RBush Remove 5k", collector);

  RBush<String> rbush;
  List<List<RBushElement<String>>> items = [];

  void run() {
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 50; j++) {
        rbush.remove(items[i][j]);
      }
    }
  }

  void setup() {
    rbush = RBush<String>(BRANCH_FACTOR);

    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        if (items.length <= i) {
          items.add([]);
        }

        final id = i.toDouble();
        final jd = j.toDouble();

        final datum = RBushElement<String>(
            minX: id,
            maxX: id + 1,
            maxY: jd,
            minY: jd - 1,
            data: 'item1 $i:$j');
        items[i].add(datum);
        rbush.insert(datum);
      }
    }
  }

  void teardown() {}
}

class SearchBenchmark extends RTreeBenchmarkBase {
  final bool iterateAll;
  final int X;
  final int Y;
  final int Z;

  SearchBenchmark(
    ScoreCollector collector, {
    this.X,
    this.Y,
    this.Z,
    this.iterateAll = false,
  }) : super("Search${iterateAll ? '/Iterate' : ''} ${X * Y * Z ~/ 1000}k",
            collector);

  RTree<String> tree;

  void run() {
    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
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

    for (int i = 0; i < X; i++) {
      for (int j = 0; j < Y; j++) {
        Rectangle rect = Rectangle(i, j, 1, 1);
        for (int k = 0; k < Z; k++) {
          tree.insert(RTreeDatum<String>(rect, 'item$k'));
        }
      }
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
