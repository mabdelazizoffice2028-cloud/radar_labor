import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Light haptic tick for field use; silently skipped where unsupported.
abstract final class FieldHaptics {
  static Future<void> attendanceChanged() async {
    try {
      await HapticFeedback.lightImpact();
    } on PlatformException catch (error) {
      debugPrint('Haptic feedback unavailable (${error.code}).');
    } on MissingPluginException {
      debugPrint('Haptic feedback plugin missing on this platform.');
    }
  }
}
