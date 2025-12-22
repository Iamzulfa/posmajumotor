/// Proportional Design Constants
/// Based on Google Pixel 9 (360px x 800px) as reference device
/// All values are in reference device pixels and will be scaled automatically
class ProportionalConstants {
  // ============================================================================
  // REFERENCE DEVICE INFO
  // ============================================================================

  static const String referenceDeviceName = 'Google Pixel 9';
  static const double referenceWidth = 360.0;
  static const double referenceHeight = 800.0;

  // ============================================================================
  // FONT SIZES (Reference Device)
  // ============================================================================

  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeDisplay = 32.0;

  // ============================================================================
  // SPACING & PADDING (Reference Device)
  // ============================================================================

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingXXXLarge = 32.0;

  // ============================================================================
  // COMPONENT SIZES (Reference Device)
  // ============================================================================

  // Button sizes
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  static const double buttonWidthSmall = 80.0;
  static const double buttonWidthMedium = 120.0;
  static const double buttonWidthLarge = 160.0;

  // Icon sizes
  static const double iconSizeXSmall = 12.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusCircle = 50.0;

  // ============================================================================
  // CARD & CONTAINER SIZES (Reference Device)
  // ============================================================================

  static const double cardPaddingSmall = 8.0;
  static const double cardPaddingMedium = 12.0;
  static const double cardPaddingLarge = 16.0;

  static const double cardHeightSmall = 80.0;
  static const double cardHeightMedium = 120.0;
  static const double cardHeightLarge = 160.0;

  // ============================================================================
  // LAYOUT DIMENSIONS (Reference Device)
  // ============================================================================

  // Screen padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 12.0;

  // Content max width (for tablets/desktop)
  static const double contentMaxWidth = 320.0; // 320px on reference device

  // Header heights
  static const double headerHeightSmall = 56.0;
  static const double headerHeightMedium = 64.0;
  static const double headerHeightLarge = 72.0;

  // ============================================================================
  // FORM ELEMENTS (Reference Device)
  // ============================================================================

  static const double inputFieldHeight = 48.0;
  static const double inputFieldPadding = 12.0;
  static const double inputFieldRadius = 8.0;

  static const double checkboxSize = 20.0;
  static const double radioButtonSize = 20.0;
  static const double switchWidth = 48.0;
  static const double switchHeight = 24.0;

  // ============================================================================
  // NAVIGATION (Reference Device)
  // ============================================================================

  static const double bottomNavHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double appBarHeight = 56.0;

  static const double drawerWidth = 280.0;
  static const double railWidth = 72.0;

  // ============================================================================
  // CHART & GRAPH SIZES (Reference Device)
  // ============================================================================

  static const double chartHeightSmall = 120.0;
  static const double chartHeightMedium = 200.0;
  static const double chartHeightLarge = 280.0;

  static const double chartPadding = 16.0;
  static const double chartLegendHeight = 32.0;

  // ============================================================================
  // MODAL & DIALOG SIZES (Reference Device)
  // ============================================================================

  static const double dialogMinWidth = 280.0;
  static const double dialogMaxWidth = 320.0;
  static const double dialogPadding = 20.0;

  static const double bottomSheetMinHeight = 200.0;
  static const double bottomSheetMaxHeight = 600.0;

  // ============================================================================
  // ANIMATION & TIMING
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================

  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================

  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.8;
  static const double opacityPressed = 0.6;
  static const double opacityOverlay = 0.3;
}
