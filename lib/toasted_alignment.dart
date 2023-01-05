import 'dart:math';

import 'package:flutter/widgets.dart';

/// Calculates the positional offset that the dialog should take relative to the [BuildContext]
/// associated with the widget that opened it.
/// For example, if the specified alignment is [Alignment.bottomRight], then since the position
/// of the dialog starts at the top-left relative to the widget that opened it, the dialog can be positioned
/// at the bottom right of that box using a positional offset of:
/// x-axis: renderBoxOffset.dx + renderBoxWidth
/// y-axis: renderBoxOffset.dy + renderBoxHeight
/// The translational offset function below is then used to translate the dialog relative to its own width,
/// since its coordinates also start top-left and to achieve a [Alignment.bottomRight] alignment, it needs
/// to be translated in the x-axis by its own width to align its right bound with the right bound of the widget that opened it
/// and in the y-axis by its own height to also align its bottom bound with the bottom of the widget that opened it.
Offset calculatePositionOffset({
  required BuildContext context,
  required Alignment alignment,
}) {
  // The insets for parts of the display that are completely obscured by system UI,
  /// typically by the device's keyboard.
  final viewInsets = MediaQuery.of(context).viewInsets;
  // The padding for parts of the display that are partially obscured by system UI like device notches.
  final devicePadding = MediaQuery.of(context).padding;
  final bottomPadding = max(viewInsets.bottom, devicePadding.bottom);
  final topPadding = devicePadding.top;
  final verticalPadding = (topPadding - bottomPadding).abs();

  // This is the render box of the widget that the dialog should be positioned relative to.
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final renderBoxSize = renderBox.size;
  final renderBoxHeight = renderBoxSize.height;
  final renderBoxWidth = renderBoxSize.width;

  final renderBoxOffset = renderBox.localToGlobal(
    Offset.zero,
  );

  if (alignment == Alignment.bottomLeft) {
    return Offset(
      renderBoxOffset.dx,
      renderBoxOffset.dy + renderBoxHeight - bottomPadding,
    );
  } else if (alignment == Alignment.bottomCenter) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth / 2,
      renderBoxOffset.dy + renderBoxHeight - bottomPadding,
    );
  } else if (alignment == Alignment.bottomRight) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth,
      renderBoxOffset.dy + renderBoxHeight - bottomPadding,
    );
  } else if (alignment == Alignment.centerLeft) {
    return Offset(
      renderBoxOffset.dx,
      renderBoxOffset.dy + (renderBoxHeight - verticalPadding) / 2,
    );
  } else if (alignment == Alignment.center) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth / 2,
      renderBoxOffset.dy + (renderBoxHeight - verticalPadding) / 2,
    );
  } else if (alignment == Alignment.centerRight) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth,
      renderBoxOffset.dy + (renderBoxHeight - verticalPadding) / 2,
    );
  } else if (alignment == Alignment.topLeft) {
    return Offset(
      renderBoxOffset.dx,
      renderBoxOffset.dy + topPadding,
    );
  } else if (alignment == Alignment.topCenter) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth / 2,
      renderBoxOffset.dy + topPadding,
    );
  } else if (alignment == Alignment.topRight) {
    return Offset(
      renderBoxOffset.dx + renderBoxWidth,
      renderBoxOffset.dy + topPadding,
    );
  }

  throw ('Unsupported alignment');
}

/// Calculates the translational offset that the dialog should take relative to the
/// [BuildContext] of the widget that opened it.
/// For example, if the specified alignment is [Alignment.bottomRight], then since positional offset calculation
/// positions the dialog at the bottom right of the widget that opened it, the translational offset will need to apply
/// an x-axis translation of Offset(-1.0, 0) since the dialog's coordinates start top-left and to have it's right bound
/// end at the right bound of the widget that opened it, it needs a negative translation equal to its own width.
Offset calculateTranslationOffset({
  required Alignment alignment,
}) {
  if (alignment == Alignment.bottomLeft) {
    return const Offset(0, -1.0);
  } else if (alignment == Alignment.bottomCenter) {
    return const Offset(-0.5, -1.0);
  } else if (alignment == Alignment.bottomRight) {
    return const Offset(-1.0, -1.0);
  } else if (alignment == Alignment.centerLeft) {
    return const Offset(0, -0.5);
  } else if (alignment == Alignment.center) {
    return const Offset(-0.5, -0.5);
  } else if (alignment == Alignment.centerRight) {
    return const Offset(-1.0, -0.5);
  } else if (alignment == Alignment.topLeft) {
    return Offset.zero;
  } else if (alignment == Alignment.topCenter) {
    return const Offset(-0.5, 0);
  } else if (alignment == Alignment.topRight) {
    return const Offset(-1.0, 0);
  }

  throw ('Unsupported alignment');
}

/// Calculates the box constraints of the toast's container based on the enclosing [BuildContext]
/// provided to the toast.
Size calculateSize({
  required BuildContext context,
}) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  return renderBox.size;
}
