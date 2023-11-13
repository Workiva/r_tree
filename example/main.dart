import 'dart:async';
import 'dart:html' hide Node;
import 'dart:math';
import 'package:r_tree/r_tree.dart';
import 'package:r_tree/src/r_tree/leaf_node.dart';
import 'package:r_tree/src/r_tree/node.dart';
import 'package:r_tree/src/r_tree/non_leaf_node.dart';
import 'package:r_tree/src/r_tree/r_tree.dart';

Future main() async {
  var rtree = RTree<String>();
  final app = querySelector('#app')!;
  final canvas = CanvasElement(width: 640, height: 480);
  app.append(canvas);
  canvas.context2D
    ..fillStyle = '#ccc'
    ..fillRect(0, 0, 640, 480);

  int? startX, startY, proposedX, proposedY;
  void draw() {
    canvas.context2D.clearRect(0, 0, 700, 500);
    canvas.context2D.strokeStyle = '';
    rtree.search(Rectangle(0, 0, 700, 500)).forEach((node) {
      canvas.context2D.fillStyle = node.value;
      canvas.context2D.fillRect(node.rect.left, node.rect.top, node.rect.width, node.rect.height);
    });

    if (proposedX != null && proposedY != null) {
      canvas.context2D.fillStyle = '';
      canvas.context2D.strokeStyle = 'black';
      canvas.context2D.strokeRect(startX!, startY!, proposedX! - startX!, proposedY! - startY!);
    }
  }

  var isDrawing = false;
  canvas.onMouseDown.listen((event) {
    final target = event.currentTarget! as HtmlElement;
    final boundingRect = target.getBoundingClientRect();
    isDrawing = true;
    proposedX = null;
    proposedY = null;

    startX = ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    startY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();
  });

  canvas.onMouseMove.listen((event) {
    if (!isDrawing || startX == null || startY == null) return;

    final target = event.currentTarget! as HtmlElement;
    final boundingRect = target.getBoundingClientRect();
    proposedX = ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    proposedY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();

    draw();
  });

  canvas.onMouseUp.listen((event) {
    isDrawing = false;
    if (startX == null || startY == null) return;

    final target = event.currentTarget! as HtmlElement;
    final boundingRect = target.getBoundingClientRect();
    final endX = ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    final endY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();

    final rectangle = Rectangle.fromPoints(Point(startX!, startY!), Point(endX, endY));
    if (currentBrush == 'search') {
      final resultList = querySelector('#results')!;
      resultList.children = [];
      for (final match in rtree.search(rectangle)) {
        var color = '';
        switch (match.value) {
          case red:
            color = 'Red';
            break;
          case green:
            color = 'Green';
            break;
          case blue:
            color = 'Blue';
            break;
          default:
            print('no match for ${match.value}');
        }
        resultList.append(LIElement()..innerHtml = '$color at ${match.rect}');
      }
      if (resultList.children.isEmpty) {
        resultList.append(LIElement()..innerHtml = 'No results in $rectangle');
      }
    } else {
      rtree.add([RTreeDatum(rectangle, currentBrush)]);
    }

    draw();
  });

  final redButton = querySelector('#red')!;
  final greenButton = querySelector('#green')!;
  final blueButton = querySelector('#blue')!;
  final searchButton = querySelector('#search')!;
  final allButtons = [redButton, greenButton, blueButton, searchButton];
  void resetAllButtons() {
    for (final element in allButtons) {
      element.style.background = '';
    }
  }

  redButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = red;
    redButton.style.background = 'darkgray';
  });
  greenButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = green;
    greenButton.style.background = 'darkgray';
  });
  blueButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = blue;
    blueButton.style.background = 'darkgray';
  });
  searchButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = 'search';
    searchButton.style.background = 'darkgray';
  });

  List<RTreeDatum<String>> makeDataset() {
    final rand = Random();
    final datum = <RTreeDatum<String>>[];
    for (var i = 0; i < 300; i++) {
      final startX = rand.nextInt((canvas.width! / 2).floor());
      final endX = rand.nextInt((canvas.width! / 2).floor()) * 2;
      final startY = rand.nextInt((canvas.height! / 2).floor());
      final endY = rand.nextInt((canvas.width! / 2).floor()) * 2;
      final color = rand.nextInt(2);
      final item = RTreeDatum(Rectangle.fromPoints(Point(startX, startY), Point(endX, endY)), colors[color]);
      datum.add(item);
    }
    return datum;
  }

  querySelector('#insert')!.onClick.listen((_) {
    makeDataset().forEach((item) => rtree.add([item]));
    draw();
  });

  querySelector('#load')!.onClick.listen((_) {
    rtree.add(makeDataset());
    draw();
  });

  querySelector('#clear')!.onClick.listen((_) {
    rtree = RTree<String>();
    draw();
  });

  querySelector('#graphviz')!.onClick.listen((_) {
    final output = querySelector('#output')! as PreElement;

    output.innerHtml = toGraphViz(getCurrentRootNode(rtree));
  });

  querySelector('#copy')!.onClick.listen((_) async {
    try {
      await window.navigator.clipboard?.writeText((querySelector('#output')! as PreElement).innerText);
      querySelector('#copy')!.style.background = 'green';
      await Future.delayed(Duration(milliseconds: 350));
      querySelector('#copy')!.style.background = '';
    } catch (err) {
      querySelector('#copy')!.style.background = 'red';
    }
  });
}

const String alpha = '88';
const String red = '#ff0000$alpha';
const String green = '#00ff00$alpha';
const String blue = '#0000ff$alpha';
const colors = [red, green, blue];
String currentBrush = red;

String toGraphViz(Node root) {
  final output = StringBuffer('''digraph r_tree {
    root [
        color="gray"
        label="root"
    ]
    ''');
  _graphVizRecurse(root, 'root', 'root', output);

  output.write('}');

  return output.toString();
}

void _graphVizRecurse(Node node, String parent, String identifierPrefix, StringBuffer buffer) {
  for (var i = 0; i < node.children.length; i++) {
    final child = node.children[i];
    if (child is LeafNode) {
      final id = '${identifierPrefix}LeafNode$i';
      buffer.write('''
      $id [
        color="green"
        label="LeafNode$i"
      ]
      $parent -> $id
''');
      for (var j = 0; j < child.children.length; j++) {
        final leafChild = child.children[j];
        final childId = '${id}LeafChild$j';
        buffer.write('''
"$childId" [
  color="orange"
  label="${leafChild.value}"
]
$id -> "$childId"
''');
      }
    } else if (child is NonLeafNode) {
      final id = '${identifierPrefix}ChildNode$i';
      buffer.write('''
 $id [
  color="brown"
  label="ChildNode$i"
 ]
 $parent -> $id
''');
      _graphVizRecurse(child, id, id, buffer);
    } else if (child is RTreeDatum) {
      final id = '${identifierPrefix}Datum$i';
      buffer.write('''
"$id" [
  color="orange"
  label="${child.value}"
]
$parent -> "$id"
''');
    }
  }
}
