import 'package:flutter/material.dart';

class SafeAreaOption {
  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  final bool bottom;

  const SafeAreaOption({
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
  });

  EdgeInsets paddingOf(BuildContext context) {
    return MediaQuery.paddingOf(context).copyWith(
      left: left ? null : 0,
      top: top ? null : 0,
      right: right ? null : 0,
      bottom: bottom ? null : 0,
    );
  }
}
