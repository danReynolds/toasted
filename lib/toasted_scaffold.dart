import 'package:flutter/material.dart';
import 'package:toasted/toasted.dart';

class ToastedScaffold extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  final ToastedTransitionsBuilder? transitionBuilder;

  const ToastedScaffold({
    required this.child,
    required this.controller,
    this.transitionBuilder,
    super.key,
  });

  @override
  ToastedScaffoldState createState() => ToastedScaffoldState();
}

class ToastedScaffoldState extends State<ToastedScaffold> {
  @override
  void initState() {
    super.initState();
    widget.controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }

  Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.linear,
      ),
      child: child,
    );
  }

  @override
  build(context) {
    final transitionBuilder =
        widget.transitionBuilder ?? _defaultTransitionBuilder;

    return transitionBuilder(
      context,
      widget.controller,
      widget.child,
    );
  }
}
