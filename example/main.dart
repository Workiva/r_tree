import 'dart:async';
import 'dart:html';
import 'package:r_tree/r_tree.dart';

Future main() async {
  var rtree = new RTree<String>();
  var app = querySelector('#app');
  var canvas = new CanvasElement(width: 640, height: 480);
  app.append(canvas);
  canvas.context2D
    ..fillStyle = '#ccc'
    ..fillRect(0, 0, 640, 480);

  int startX, startY;
  canvas.onMouseDown.listen((MouseEvent event) {
    var target = event.currentTarget as HtmlElement;
    var boundingRect = target.getBoundingClientRect();
    startX = ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    startY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();
  });

  canvas.onMouseUp.listen((MouseEvent event) {
    if (startX == null || startY == null) return;

    var target = event.currentTarget as HtmlElement;
    var boundingRect = target.getBoundingClientRect();
    var endX =
        ((event.client.x - boundingRect.left) + target.scrollLeft).floor();
    var endY = ((event.client.y - boundingRect.top) + target.scrollTop).floor();

    var rectangle = new Rectangle(startX, startY, endX - startX, endY - startY);

    if (currentBrush == 'search') {
      var resultList = querySelector('#results');
      resultList.children = [];
      for (RTreeDatum match in rtree.search(rectangle)) {
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
        resultList
            .append(new LIElement()..innerHtml = '$color at ${match.rect}');
      }
      if (resultList.children.isEmpty) {
        resultList
            .append(new LIElement()..innerHtml = 'No results in $rectangle');
      }
    } else {
      canvas.context2D.fillStyle = currentBrush;
      canvas.context2D.fillRect(startX, startY, endX - startX, endY - startY);
      rtree.insert(new RTreeDatum(rectangle, currentBrush));
    }
  });

  querySelector('#red').onClick.listen((_) => currentBrush = '$red');
  querySelector('#green').onClick.listen((_) => currentBrush = '$green');
  querySelector('#blue').onClick.listen((_) => currentBrush = '$blue');
  querySelector('#search').onClick.listen((_) => currentBrush = 'search');
}

const String alpha = '88';
const String red = '#ff0000$alpha';
const String green = '#00ff00$alpha';
const String blue = '#0000ff$alpha';
String currentBrush = '$red';
