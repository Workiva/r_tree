import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:r_tree/r_tree.dart';

Future main() async {
  var rtree = RTree<String>();
  var app = querySelector('#app')!;
  var canvas = CanvasElement(width: 640, height: 480);
  app.append(canvas);
  canvas.context2D
    ..fillStyle = '#ccc'
    ..fillRect(0, 0, 640, 480);

  int? startX, startY, proposedX, proposedY;
  final draw = () {
    canvas.context2D.clearRect(0, 0, 700, 500);
    canvas.context2D.strokeStyle = '';
    rtree.search(Rectangle(0, 0, 700, 500)).forEach((node) {
      canvas.context2D.fillStyle = node.value;
      canvas.context2D.fillRect(
          node.rect.left, node.rect.top, node.rect.width, node.rect.height);
    });

    if (proposedX != null && proposedY != null) {
      canvas.context2D.fillStyle = '';
      canvas.context2D.strokeStyle = 'black';
      canvas.context2D.strokeRect(
          startX!, startY!, proposedX! - startX!, proposedY! - startY!);
    }
  };

  var isDrawing = false;
  canvas.onMouseDown.listen((MouseEvent event) {
    var target = event.currentTarget as HtmlElement;
    var boundingRect = target.getBoundingClientRect();
    isDrawing = true;
    proposedX = null;
    proposedY = null;

    startX = ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    startY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();
  });

  canvas.onMouseMove.listen((MouseEvent event) {
    if (!isDrawing || startX == null || startY == null) return;

    var target = event.currentTarget as HtmlElement;
    var boundingRect = target.getBoundingClientRect();
    proposedX =
        ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    proposedY =
        ((event.client.y - boundingRect.top) + target.scrollTop).floor();

    draw();
  });

  canvas.onMouseUp.listen((MouseEvent event) {
    isDrawing = false;
    if (startX == null || startY == null) return;

    var target = event.currentTarget as HtmlElement;
    var boundingRect = target.getBoundingClientRect();
    var endX =
        ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    var endY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();

    var rectangle =
        Rectangle.fromPoints(Point(startX!, startY!), Point(endX, endY));
    if (currentBrush == 'search') {
      var resultList = querySelector('#results')!;
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
      rtree.insert(RTreeDatum(rectangle, currentBrush));
    }

    draw();
  });

  final redButton = querySelector('#red')!;
  final greenButton = querySelector('#green')!;
  final blueButton = querySelector('#blue')!;
  final searchButton = querySelector('#search')!;
  final allButtons = [redButton, greenButton, blueButton, searchButton];
  final resetAllButtons = () => allButtons.forEach((element) {
        element.style.background = '';
      });
  redButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = '$red';
    redButton.style.background = 'darkgray';
  });
  greenButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = '$green';
    greenButton.style.background = 'darkgray';
  });
  blueButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = '$blue';
    blueButton.style.background = 'darkgray';
  });
  searchButton.onClick.listen((_) {
    resetAllButtons();
    currentBrush = 'search';
    searchButton.style.background = 'darkgray';
  });

  final makeDataset = () {
    Random rand = Random();
    var datum = <RTreeDatum<String>>[];
    for (int i = 0; i < 300; i++) {
      int startX = rand.nextInt((canvas.width! / 2).floor());
      int endX = rand.nextInt((canvas.width! / 2).floor()) * 2;
      int startY = rand.nextInt((canvas.height! / 2).floor());
      int endY = rand.nextInt((canvas.width! / 2).floor()) * 2;
      int color = rand.nextInt(2);
      var item = RTreeDatum(
          Rectangle.fromPoints(Point(startX, startY), Point(endX, endY)),
          colors[color]);
      datum.add(item);
    }
    return datum;
  };

  querySelector('#insert')!.onClick.listen((_) {
    makeDataset().forEach(rtree.insert);
    draw();
  });

  querySelector('#load')!.onClick.listen((_) {
    rtree.load(makeDataset());
    draw();
  });

  querySelector('#clear')!.onClick.listen((_) {
    rtree = RTree<String>();
    draw();
  });

  querySelector('#graphviz')!.onClick.listen((_) {
    var output = querySelector('#output') as PreElement;
    output.innerHtml = rtree.toGraphViz();
  });

  querySelector('#copy')!.onClick.listen((_) async {
    try {
      await window.navigator.clipboard
          ?.writeText((querySelector('#output') as PreElement).innerText);
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
String currentBrush = '$red';
