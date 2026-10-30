import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tactile sensory feedback for field operations.
abstract final class FieldHaptics {
  static Future<void> _safeTrigger(
    Future<void> Function() action,
    String label,
  ) async {
    try {
      await action();
    } on PlatformException catch (error) {
      debugPrint('Haptic $label unavailable (${error.code}).');
    } on MissingPluginException {
      debugPrint('Haptic plugin missing on this platform ($label).');
    }
  }

  /// Light tick when attendance state transitions.
  static Future<void> attendanceChanged() =>
      _safeTrigger(HapticFeedback.lightImpact, 'attendanceChanged');

  /// Medium impact on successful save operations.
  static Future<void> success() =>
      _safeTrigger(HapticFeedback.mediumImpact, 'success');

  /// Heavy impact on errors or validation failures.
  static Future<void> error() =>
      _safeTrigger(HapticFeedback.heavyImpact, 'error');

  /// Selection click when picking or toggling items in lists.
  static Future<void> selection() =>
      _safeTrigger(HapticFeedback.selectionClick, 'selection');
}
