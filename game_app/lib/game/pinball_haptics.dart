import 'dart:async';

import 'package:flutter/services.dart';

enum PinballHaptic { light, medium, heavy }

/// Small haptic bus that records feedback for tests and optionally forwards it
/// to the current phone platform.
class PinballHaptics {
  PinballHaptics({this.enablePlatform = false, this.enabled = true});

  final bool enablePlatform;
  bool enabled;
  final List<PinballHaptic> events = <PinballHaptic>[];

  void light() => _trigger(PinballHaptic.light);

  void medium() => _trigger(PinballHaptic.medium);

  void heavy() => _trigger(PinballHaptic.heavy);

  void clear() => events.clear();

  void _trigger(PinballHaptic haptic) {
    if (!enabled) {
      return;
    }
    events.add(haptic);
    if (!enablePlatform) {
      return;
    }

    unawaited(_send(haptic));
  }

  Future<void> _send(PinballHaptic haptic) {
    return switch (haptic) {
      PinballHaptic.light => HapticFeedback.lightImpact(),
      PinballHaptic.medium => HapticFeedback.mediumImpact(),
      PinballHaptic.heavy => HapticFeedback.heavyImpact(),
    };
  }
}
