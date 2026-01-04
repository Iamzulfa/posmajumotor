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

  /// Calculate responsive width using the formula: (size / 360) * device_width with constraints
  static double getResponsiveWidth(double deviceWidth, double size) {
    double scaledValue = (size / referenceWidth) * deviceWidth;

    // Apply constraints based on device type to prevent excessive scaling
    if (deviceWidth > phoneMaxWidth) {
      // Tablet and desktop
      // Limit scaling on larger devices
      double maxScale = size * (deviceWidth > tabletMaxWidth ? 1.6 : 1.4);
      if (scaledValue > maxScale) scaledValue = maxScale;
    }

    return scaledValue;
  }

  /// Calculate responsive height using the formula: (size / 800) * device_height with constraints
  static double getResponsiveHeight(double deviceHeight, double size) {
    double scaledValue = (size / referenceHeight) * deviceHeight;

    // Apply constraints to prevent excessive height scaling
    double maxScale = size * 1.5;
    if (scaledValue > maxScale) scaledValue = maxScale;

    return scaledValue;
  }

  /// Get device type based on width
  static String getDeviceType(double width) {
    if (width < phoneMaxWidth) return 'phone';
    if (width < tabletMaxWidth) return 'tablet';
    return 'desktop';
  }
}
