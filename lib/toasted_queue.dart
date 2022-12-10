import 'dart:async';

import 'package:toasted/toasted.dart';

enum ToastedState {
  none,
  transitionIn,
  display,
  transitionOut;

  Duration get duration {
    switch (this) {
      case ToastedState.display:
        return const Duration(seconds: 3);
      case ToastedState.transitionIn:
      case ToastedState.transitionOut:
        return const Duration(milliseconds: 250);
      case ToastedState.none:
        return Duration.zero;
    }
  }
}

class ToastedQueueChangeEvent {
  final Toasted? toast;
  final ToastedState state;

  ToastedQueueChangeEvent({
    required this.toast,
    required this.state,
  });
}

class ToastedQueue {
  final List<Toasted> _queue = [];
  Timer? _timer;
  ToastedState _state = ToastedState.none;
  final void Function(ToastedQueueChangeEvent event)? onEvent;

  ToastedQueue({
    this.onEvent,
  });

  _onEvent() {
    final event = ToastedQueueChangeEvent(
      toast: _queue.isNotEmpty ? _queue.first : null,
      state: _state,
    );
    onEvent?.call(event);
  }

  enqueue(Toasted toast) {
    _queue.add(toast);

    if (_state == ToastedState.none) {
      _next();
    }
  }

  dequeue() {
    if (_state == ToastedState.transitionIn || _state == ToastedState.display) {
      _timer!.cancel();
      _timer = null;
      _state = ToastedState.display;
      _next();
    }
  }

  clear() {
    if (_state == ToastedState.none) {
      return;
    }
    _timer!.cancel();
    _timer = null;
    _state = ToastedState.none;
    _onEvent();
    // Clear the queue last so that if there is a current toast displayed
    // when the queue is cleared, it will be passed along in the onEvent handler.
    _queue.clear();
  }

  _next() {
    switch (_state) {
      case ToastedState.none:
        _state = ToastedState.transitionIn;
        _onEvent();
        _timer = Timer(
          _queue.first.transitionInDuration ?? _state.duration,
          _next,
        );
        break;
      case ToastedState.transitionIn:
        _state = ToastedState.display;
        _onEvent();
        _timer = Timer(_queue.first.duration ?? _state.duration, _next);
        break;
      case ToastedState.display:
        _state = ToastedState.transitionOut;
        _onEvent();
        _timer = Timer(
          _queue.first.transitionOutDuration ?? _state.duration,
          _next,
        );
        break;
      case ToastedState.transitionOut:
        _queue.removeAt(0);
        _state = ToastedState.none;

        if (_queue.isNotEmpty) {
          _next();
        }
        break;
    }
  }
}
