import 'dart:html';

import 'benchmarks.dart' as benchmarks;

main() {
  final button = querySelector('#runButton')! as ButtonElement;
  button.onClick.listen((_) async {
    button.disabled = true;
    final text = button.innerText;
    button.innerText = 'Running';
    await window.animationFrame;
    await window.animationFrame;
    await window.animationFrame;
    benchmarks.main();
    button.disabled = false;
    button.innerText = text;
  });
}
