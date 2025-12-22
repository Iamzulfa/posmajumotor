import 'package:flutter/material.dart';

/// Proportional Responsive System
/// Based on formula: (widget_size / reference_size) * device_size
/// Reference Device: Google Pixel 9 (360px width, 800px height)
class ProportionalResponsive {
  // ============================================================================
  // REFERENCE DEVICE DIMENSIONS (Google Pixel 9)
  // ============================================================================

  /// Reference width (Google Pixel 9)
  static const double referenceWidth = 360.0;

  /// Reference height (Google Pixel 9)
  static const double referenceHeight = 800.0;

  // ============================================================================
  // CORE SCALING METHODS
  // ============================================================================

  /// Get current device width
  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get current device height
  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Scale width proportionally
  /// Formula: (widget_width / reference_width) * device_width
  static double scaleWidth(BuildContext context, double widgetWidth) {
    final deviceWidth = getDeviceWidth(context);
    return (widgetWidth / referenceWidth) * deviceWidth;
  }

  /// Scale height proportionally
  /// Formula: (widget_height / reference_height) * device_height
  static double scaleHeight(BuildContext context, double widgetHeight) {
    final deviceHeight = getDeviceHeight(context);
    return (widgetHeight / referenceHeight) * deviceHeight;
  }

  /// Scale size (both width and height)
  static Size scaleSize(BuildContext context, Size originalSize) {
    return Size(
      scaleWidth(context, originalSize.width),
      scaleHeight(context, originalSize.height),
    );
  }

  // ============================================================================
  // CONVENIENCE METHODS
  // ============================================================================

  /// Scale font size proportionally (based on width scaling)
  static double scaleFontSize(BuildContext context, double fontSize) {
    return scaleWidth(context, fontSize);
  }

  /// Scale padding/margin proportionally
  static EdgeInsets scalePadding(BuildContext context, EdgeInsets padding) {
    return EdgeInsets.only(
      left: scaleWidth(context, padding.left),
      top: scaleHeight(context, padding.top),
      right: scaleWidth(context, padding.right),
      bottom: scaleHeight(context, padding.bottom),
    );
  }

  /// Scale symmetric padding
  static EdgeInsets scaleSymmetricPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: scaleWidth(context, horizontal),
      vertical: scaleHeight(context, vertical),
    );
  }

  /// Scale all padding (uniform)
  static EdgeInsets scaleAllPadding(BuildContext context, double padding) {
    return EdgeInsets.all(scaleWidth(context, padding));
  }

  /// Scale border radius
  static BorderRadius scaleBorderRadius(BuildContext context, double radius) {
    return BorderRadius.circular(scaleWidth(context, radius));
  }

  /// Scale icon size
  static double scaleIconSize(BuildContext context, double iconSize) {
    return scaleWidth(context, iconSize);
  }

  // ============================================================================
  // WIDGET HELPERS
  // ============================================================================

  /// Create scaled SizedBox with width
  static Widget scaledWidthBox(BuildContext context, double width) {
    return SizedBox(width: scaleWidth(context, width));
  }

  /// Create scaled SizedBox with height
  static Widget scaledHeightBox(BuildContext context, double height) {
    return SizedBox(height: scaleHeight(context, height));
  }

  /// Create scaled SizedBox with both dimensions
  static Widget scaledBox(BuildContext context, double width, double height) {
    return SizedBox(
      width: scaleWidth(context, width),
      height: scaleHeight(context, height),
    );
  }

  // ============================================================================
  // DEBUG & UTILITY METHODS
  // ============================================================================

  /// Get scaling factors for debugging
  static Map<String, double> getScalingFactors(BuildContext context) {
    final deviceWidth = getDeviceWidth(context);
    final deviceHeight = getDeviceHeight(context);

    return {
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'widthScaleFactor': deviceWidth / referenceWidth,
      'heightScaleFactor': deviceHeight / referenceHeight,
      'referenceWidth': referenceWidth,
      'referenceHeight': referenceHeight,
    };
  }

  /// Check if current device is the reference device
  static bool isReferenceDevice(BuildContext context) {
    final deviceWidth = getDeviceWidth(context);
    final deviceHeight = getDeviceHeight(context);

    return (deviceWidth == referenceWidth && deviceHeight == referenceHeight);
  }

  /// Get device info string for debugging
  static String getDeviceInfo(BuildContext context) {
    final factors = getScalingFactors(context);
    return '''
Device: ${factors['deviceWidth']}x${factors['deviceHeight']}
Reference: ${factors['referenceWidth']}x${factors['referenceHeight']}
Scale Factors: W=${factors['widthScaleFactor']?.toStringAsFixed(2)}, H=${factors['heightScaleFactor']?.toStringAsFixed(2)}
''';
  }
}
