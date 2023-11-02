part of r_tree;
// Port of https://github.com/mourner/quickselect.

// sort an array so that items come in groups of n unsorted items, with groups sorted between each other;
// combines selection algorithm with binary divide & conquer approach
multiSelect<E>(
    List<E> arr, int left, int right, int n, int Function(E a, E b) compare) {
  final stack = [left, right];

  while (stack.isNotEmpty) {
    right = stack.removeLast();
    left = stack.removeLast();

    if (right - left <= n) {
      continue;
    }

    final mid = left + ((right - left).toDouble() / n / 2).ceil() * n;
    quickSelect(arr, mid, left, right, compare);
    stack.addAll([left, mid, mid, right]);
  }
}

/// This function implements a fast
/// [selection algorithm](https://en.wikipedia.org/wiki/Selection_algorithm)
/// (specifically, [Floyd-Rivest selection](https://en.wikipedia.org/wiki/Floyd%E2%80%93Rivest_algorithm)).
///
/// Rearranges items so that all items in the `[left, k]` are the smallest.
/// The `k`-th element will have the `(k - left + 1)`-th smallest value in `[left, right]`.
///
/// - [arr]: the list to partially sort (in place)
/// - [k]: middle index for partial sorting (as defined above)
/// - [left]: left index of the range to sort
/// - [right]: right index of the range to sort
/// - [compare]: compare function
///
/// Example:
///
/// ```dart
/// var arr = [65, 28, 59, 33, 21, 56, 22, 95, 50, 12, 90, 53, 28, 77, 39];
///
/// quickSelect(arr, 8);
///
/// // arr is [39, 28, 28, 33, 21, 12, 22, 50, 53, 56, 59, 65, 90, 77, 95]
/// //                                         ^^ middle index
/// ```
void quickSelect<T>(List<T> arr, int k, int left, int right, Comparator<T> compare) {
  if (arr.isEmpty) {
    return;
  }

  _quickSelectStep(arr, k, left, right, compare);
}

void _quickSelectStep<T>(List<T> arr, int k, int left, int right, Comparator<T> compare) {
  while (right > left) {
    if (right - left > 600) {
      final n = right - left + 1;
      final m = k - left + 1;
      final z = log(n);
      final s = 0.5 * exp(2 * z / 3);
      final sd = 0.5 * sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1);
      final newLeft = max(left, (k - m * s / n + sd).floor());
      final newRight = min(right, (k + (n - m) * s / n + sd).floor());

      _quickSelectStep(arr, k, newLeft, newRight, compare);
    }

    final t = arr[k];
    var i = left;
    var j = right;

    _swap(arr, left, k);

    if (compare(arr[right], t) > 0) {
      _swap(arr, left, right);
    }

    while (i < j) {
      _swap(arr, i, j);

      i++;
      j--;

      while (compare(arr[i], t) < 0) {
        i++;
      }

      while (compare(arr[j], t) > 0) {
        j--;
      }
    }

    if (compare(arr[left], t) == 0) {
      _swap(arr, left, j);
    } else {
      j++;
      _swap(arr, j, right);
    }

    if (j <= k) {
      left = j + 1;
    }
    if (k <= j) {
      right = j - 1;
    }
  }
}

void _swap<T>(List<T> arr, i, j) {
  final tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}
