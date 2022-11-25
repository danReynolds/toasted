import 'package:flutter/widgets.dart';
import 'package:toasted/toasted_queue.dart';
import 'package:toasted/toasted_messenger.dart';
import 'package:toasted/toasted_scaffold.dart';

import 'toasted.dart';

class _ToastedProviderEntry {
  final OverlayEntry overlay;
  final AnimationController animation;

  _ToastedProviderEntry({
    required this.overlay,
    required this.animation,
  });
}

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
        final toast = event.toast;
        final state = event.state;

        switch (event.state) {
          case ToastedState.transitionIn:
            final overlayState = Overlay.of(toast!.context)!;

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
            if (toast != null) {
              _entries[toast]!.overlay.remove();
            }
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
