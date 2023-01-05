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
  final _toastEventStreamController =
      StreamController<ToastedQueueChangeEvent>();
  late final Stream<ToastedQueueChangeEvent> eventStream;

  ToastedQueue() {
    eventStream = _toastEventStreamController.stream.asBroadcastStream();
  }

  dispose() {
    _toastEventStreamController.close();
  }

  _onEvent() {
    final event = ToastedQueueChangeEvent(
      toast: _queue.isNotEmpty ? _queue.first : null,
      state: _state,
    );
    _toastEventStreamController.add(event);
  }

  /// Returns a future that waits for the given toast to be dequeued.
  Future<void> _onToastDequeued(Toasted toast) {
    return eventStream.where((event) {
      final state = event.state;

      /// If the queue state enters [ToastedState.none], or it has moved on to
      /// the next toast after the given toast, then the event for dequeuing can be fired.
      return state == ToastedState.none ||
          state == ToastedState.transitionIn && !_queue.contains(toast);
    }).first;
  }

  /// Enqueues a [Toasted] toast. Returns a future that completes the toast is removed from the queue either after it transitions
  /// out or when the queue is cleared.
  Future<void> enqueue(Toasted toast) {
    final onDequeued = _onToastDequeued(toast);

    _queue.add(toast);
    if (_state == ToastedState.none) {
      _next();
    }

    return onDequeued;
  }

  /// Immediately transitions the current [Toasted] toast out. Returns a future
  /// that completes when the toast has been successfully dequeued or immediately if the queue is empty.
  Future<void> dequeue() async {
    if (_state == ToastedState.none) {
      return;
    }

    final toast = _queue.first;
    final onDequeued = _onToastDequeued(toast);

    if (_state == ToastedState.transitionIn || _state == ToastedState.display) {
      _timer!.cancel();
      _timer = null;
      _state = ToastedState.display;
      _next();
    }

    return onDequeued;
  }

  void clear() {
    if (_state == ToastedState.none) {
      return;
    }

    _timer!.cancel();
    _timer = null;
    _state = ToastedState.none;
    _queue.clear();
    _onEvent();
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

        if (_queue.isEmpty) {
          _onEvent();
        } else {
          _next();
        }
        break;
    }
  }
}
