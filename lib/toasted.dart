library toasted;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toasted/toasted_queue.dart';
import 'package:toasted/toasted_scaffold.dart';

import 'toasted_alignment.dart';

export 'package:toasted/toasted.dart';
export 'package:toasted/toasted_queue.dart';

typedef ToastedTransitionsBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

class Toasted {
  /// The duration that the toast should be shown for.
  final Duration? duration;

  /// The duration of the transition-in toast animation.
  final Duration? transitionInDuration;

  /// The duration of the transition-out toast animation.
  final Duration? transitionOutDuration;

  /// The transition that the toast should use to animate in/out. Defaults to a fade transition.
  final ToastedTransitionsBuilder? transitionBuilder;

  /// The child widget to display in the toast.
  final Widget child;

  /// The alignment of the toast relative to its enclosing context. Defaults to [Alignment.bottomRight]
  /// since toasts generally appear at the bottom-right in most applications.
  final Alignment alignment;

  /// The optional [BuildContext] of the widget that the toasted should be positioned relative to.
  /// If not provided, the global context of the [ToastedProvider] will be used.
  final BuildContext? context;

  Toasted({
    required this.child,
    this.transitionBuilder,
    this.duration,
    this.transitionInDuration,
    this.transitionOutDuration,
    this.context,
    this.alignment = Alignment.bottomRight,
  });

  Toasted _withContext(BuildContext context) {
    return Toasted(
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

  /// Displays the [Toasted] toast as an [Overlay] on top of the route stack. Returns
  /// a [Future] which completes when the toast has been dismissed.
  Future<void> show(Toasted toast) {
    if (toast.context != null) {
      return queue.enqueue(toast);
    }
    return queue.enqueue(toast._withContext(_context!));
  }

  /// Dismisses the [Toasted] toast, immediately causing it to perform its transition out animation.
  /// Returns a [Future] which completes when the animation has finished.
  Future<void> dismiss() {
    return queue.dequeue();
  }

  /// Immediately clears the current [Toasted] toast without a transition animation and clears all other enqueued toasts.
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
  late final StreamSubscription<ToastedQueueChangeEvent>
      _toastEventSubscription;
  Toasted? _currentToast;

  @override
  initState() {
    super.initState();

    _queue = ToastedQueue();
    _toastEventSubscription = _queue.eventStream.listen((event) {
      final toast = event.toast;
      final state = event.state;

      switch (event.state) {
        case ToastedState.transitionIn:
          _currentToast = toast!;
          final overlayState = Navigator.of(toast.context!).overlay!;

          final controller = AnimationController(
            vsync: this,
            duration: toast.transitionInDuration ?? state.duration,
            reverseDuration: toast.transitionOutDuration ??
                ToastedState.transitionOut.duration,
          );

          final entry = _ToastedProviderEntry(
            overlay: OverlayEntry(
              builder: (context) {
                final alignment = toast.alignment;
                final toastContext = toast.context!;

                final position = calculatePositionOffset(
                  context: toastContext,
                  alignment: alignment,
                );
                final translation = calculateTranslationOffset(
                  alignment: alignment,
                );
                final size = calculateSize(context: toastContext);

                return Positioned(
                  top: position.dy,
                  left: position.dx,
                  child: FractionalTranslation(
                    translation: translation,
                    child: ToastedScaffold(
                      controller: controller,
                      transitionBuilder: toast.transitionBuilder,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: toast.child,
                      ),
                    ),
                  ),
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
            final entry = _entries[toast];
            // The entry may already have been removed if the state has been advanced
            // to [ToastedState.none] via a call to [clear()] for example while
            // transitioning out.
            if (entry != null) {
              entry.overlay.remove();
              _entries.remove(toast);
            }
          });
          break;
        case ToastedState.none:
          if (_currentToast != null) {
            _entries[_currentToast]!.overlay.remove();
          }
          _currentToast = null;
          _entries.clear();
          break;
        case ToastedState.display:
          break;
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    _toastEventSubscription.cancel();
  }

  @override
  build(context) {
    return ToastedMessenger(
      queue: _queue,
      child: widget.child,
    );
  }
}
