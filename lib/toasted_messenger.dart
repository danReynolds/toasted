library toasted;

import 'package:flutter/material.dart';
import 'package:toasted/toasted.dart';
import 'package:toasted/toasted_queue.dart';

class ToastedMessenger extends InheritedWidget {
  final ToastedQueue queue;

  const ToastedMessenger({
    required super.child,
    required this.queue,
    super.key,
  });

  @override
  bool updateShouldNotify(ToastedMessenger oldWidget) => false;

  static ToastedMessenger? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToastedMessenger>();
  }

  /// Displays the [Toasted] toast as an [Overlay] on top of the route stack.
  void show(Toasted toast) {
    queue.enqueue(toast);
  }

  /// Immediately dismisses the current [Toasted] toast.
  void dismiss() {
    queue.dequeue();
  }

  /// Immediately dismissed the current [Toasted] toast and clears all other enqueued toasts.
  void clear() {
    queue.clear();
  }
}
