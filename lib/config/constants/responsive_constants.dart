/// Essential Responsive Constants
/// Based on Google Pixel 9 (360px x 800px) reference device
/// Formula: (widget_size / reference_size) * device_size
class ResponsiveConstants {
  // ============================================================================
  // REFERENCE DEVICE (Google Pixel 9)
  // ============================================================================

  static const double referenceWidth = 360.0;
  static const double referenceHeight = 800.0;
  static const String referenceDevice = 'Google Pixel 9';

  // ============================================================================
  // DEVICE BREAKPOINTS
  // ============================================================================

  static const double phoneMaxWidth = 600.0;
  static const double tabletMaxWidth = 1000.0;
  // Desktop: > 1000px

  // ============================================================================
  // COMMON DIMENSIONS (Reference Device Values)
  // ============================================================================

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;

  // Font Sizes
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;

  // Icon Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // Card Heights
  static const double cardHeightSm = 80.0;
  static const double cardHeightMd = 120.0;
  static const double cardHeightLg = 160.0;

  // ============================================================================
  // RESPONSIVE SCALING HELPERS
  // ============================================================================

  /// Calculate responsive width using the formula: (size / 360) * device_width
  static double getResponsiveWidth(double deviceWidth, double size) {
    return (size / referenceWidth) * deviceWidth;
  }

  /// Calculate responsive height using the formula: (size / 800) * device_height
  static double getResponsiveHeight(double deviceHeight, double size) {
    return (size / referenceHeight) * deviceHeight;
  }

  /// Get device type based on width
  static String getDeviceType(double width) {
    if (width < phoneMaxWidth) return 'phone';
    if (width < tabletMaxWidth) return 'tablet';
    return 'desktop';
  }
}
