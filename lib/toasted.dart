import 'package:flutter/widgets.dart';

typedef ToastedTransitionsBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

class Toasted {
  final BuildContext context;
  final Duration? duration;
  final Duration? transitionInDuration;
  final Duration? transitionOutDuration;
  final ToastedTransitionsBuilder? transitionBuilder;
  final Widget child;

  Toasted({
    required this.context,
    required this.child,
    this.transitionBuilder,
    this.duration,
    this.transitionInDuration,
    this.transitionOutDuration,
  });
}
