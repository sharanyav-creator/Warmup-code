import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

/// Shows the "Remove Track" context menu at [globalPosition] (the long-press
/// point), matching the Figma popup component. Calls [onRemove] if tapped.
Future<void> showRemoveTrackPopup(
  BuildContext context, {
  required Offset globalPosition,
  required VoidCallback onRemove,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final selected = await showMenu<bool>(
    context: context,
    position: RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    ),
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    items: [
      PopupMenuItem<bool>(
        value: true,
        child: Text(
          'Remove Track',
          style: OnboardingText.headline(color: OnboardingColors.textDark1f, fontSize: 14),
        ),
      ),
    ],
  );
  if (selected == true) onRemove();
}
