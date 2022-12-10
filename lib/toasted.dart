library toasted;

import 'package:flutter/material.dart';
import 'package:toasted/toasted_queue.dart';
import 'package:toasted/toasted_scaffold.dart';

export 'package:toasted/toasted.dart';
export 'package:toasted/toasted_queue.dart';

typedef ToastedTransitionsBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

class Toasted {
  final Duration? duration;
  final Duration? transitionInDuration;
  final Duration? transitionOutDuration;
  final ToastedTransitionsBuilder? transitionBuilder;
  final Widget child;

  /// This field is used by [ToastedProvider] to retrieve the [Overlay] associated
  /// with the current [BuildContext].
  /// ignore: unused_field
  BuildContext? _context;

  Toasted({
    required this.child,
    this.transitionBuilder,
    this.duration,
    this.transitionInDuration,
    this.transitionOutDuration,
  });

  Toasted._withContext({
    required BuildContext context,
    required this.child,
    this.transitionBuilder,
    this.duration,
    this.transitionInDuration,
    this.transitionOutDuration,
  }) : _context = context;

  Toasted _withContext(BuildContext context) {
    return Toasted._withContext(
      child: child,
      transitionBuilder: transitionBuilder,
      duration: duration,
      transitionInDuration: transitionInDuration,
      transitionOutDuration: transitionOutDuration,
      context: context,
    );
  }
}

/// The [ToastedMessenger] inherited widget is inserted at the top of the build tree
/// by the [ToastedProvider] and provides access to the toasted actions from descendant contexts.
class ToastedMessenger extends InheritedWidget {
  final ToastedQueue queue;

  /// ignore: unused_field
  final BuildContext? _context;

  const ToastedMessenger({
    required super.child,
    required this.queue,
    super.key,
  }) : _context = null;

  const ToastedMessenger._withContext({
    required BuildContext context,
    required super.child,
    required this.queue,
    super.key,
  }) : _context = context;

  ToastedMessenger _withContext(BuildContext context) {
    return ToastedMessenger._withContext(
      queue: queue,
      context: context,
      key: key,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(ToastedMessenger oldWidget) => false;

  static ToastedMessenger? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ToastedMessenger>()
        // The BuildContext of the caller accessing the ToastedMessenger
        // is then associated with a copy of the messenger so that that BuildContext
        // can be used to retrieve the local Navigator when displaying a Toast without
        // having to pass in the context explicitly.
        ?._withContext(context);
  }

  /// Displays the [Toasted] toast as an [Overlay] on top of the route stack.
  void show(Toasted toast) {
    queue.enqueue(toast._withContext(_context!));
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

class _ToastedProviderEntry {
  final OverlayEntry overlay;
  final AnimationController animation;

  _ToastedProviderEntry({
    required this.overlay,
    required this.animation,
  });
}

/// The provider class placed at the top of the build tree that injects a [ToastedMessenger] used to
/// access the toast actions from any descendants in the build tree.
class ToastedProvider extends StatefulWidget {
  final Widget child;

  const ToastedProvider({
    required this.child,
    super.key,
  });

  @override
  ToastedProviderState createState() => ToastedProviderState();
}

class ToastedProviderState extends State<ToastedProvider>
    with TickerProviderStateMixin {
  late final ToastedQueue _queue;
  final Map<Toasted, _ToastedProviderEntry> _entries = {};

  @override
  initState() {
    super.initState();

    _queue = ToastedQueue(
      onEvent: (event) {
        final toast = event.toast!;
        final state = event.state;

        switch (event.state) {
          case ToastedState.transitionIn:
            final overlayState = Navigator.of(toast._context!).overlay!;

            final controller = AnimationController(
              vsync: this,
              duration: toast.transitionInDuration ?? state.duration,
              reverseDuration: toast.transitionOutDuration ??
                  ToastedState.transitionOut.duration,
            );

            final entry = _ToastedProviderEntry(
              overlay: OverlayEntry(
                builder: (context) {
                  return ToastedScaffold(
                    controller: controller,
                    transitionBuilder: toast.transitionBuilder,
                    child: toast.child,
                  );
                },
              ),
              animation: controller,
            );

            _entries[toast] = entry;
            overlayState.insert(entry.overlay);

            break;
          case ToastedState.transitionOut:
            _entries[toast]!.animation.reverse().then((value) {
              final entry = _entries[toast]!;
              entry.overlay.remove();
              _entries.remove(toast);
            });
            break;
          case ToastedState.none:
            _entries[toast]!.overlay.remove();
            _entries.clear();
            break;
          case ToastedState.display:
            break;
        }
      },
    );
  }

  @override
  build(context) {
    return ToastedMessenger(
      queue: _queue,
      child: widget.child,
    );
  }
}
