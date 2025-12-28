import 'package:flutter/services.dart';
import 'logger.dart';

/// Haptic Feedback Utility
class HapticFeedbackUtils {
  /// Light tap feedback - untuk normal interactions
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Medium feedback - untuk important actions
  static Future<void> mediumTap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Heavy feedback - untuk critical actions atau errors
  static Future<void> heavyTap() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Selection changed feedback
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Success feedback - short vibration
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Error feedback - strong vibration
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }

  /// Warning feedback - medium vibration
  static Future<void> warning() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.debug('Haptic feedback not available: $e');
    }
  }
}
