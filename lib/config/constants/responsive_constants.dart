/// Responsive design constants for consistent sizing across devices
class ResponsiveConstants {
  // ============================================================================
  // DEVICE BREAKPOINTS
  // ============================================================================

  /// Phone breakpoints
  static const double phoneSmall = 320;
  static const double phoneMedium = 360;
  static const double phoneLarge = 480;

  /// Tablet breakpoints
  static const double tabletSmall = 600;
  static const double tabletMedium = 768;
  static const double tabletLarge = 900;

  /// Desktop breakpoints
  static const double desktopSmall = 1000;
  static const double desktopMedium = 1200;
  static const double desktopLarge = 1440;

  // ============================================================================
  // PADDING & MARGIN
  // ============================================================================

  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 12;
  static const double paddingLarge = 16;
  static const double paddingXLarge = 20;
  static const double paddingXXLarge = 24;
  static const double paddingXXXLarge = 32;

  // ============================================================================
  // FONT SIZES
  // ============================================================================

  static const double fontSizeXSmall = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeMedium = 14;
  static const double fontSizeLarge = 16;
  static const double fontSizeXLarge = 18;
  static const double fontSizeXXLarge = 20;
  static const double fontSizeTitle = 24;
  static const double fontSizeHeading = 28;
  static const double fontSizeXXXLarge = 32;

  // ============================================================================
  // BUTTON SIZES
  // ============================================================================

  static const double buttonHeightSmall = 36;
  static const double buttonHeightMedium = 44;
  static const double buttonHeightLarge = 52;

  static const double buttonWidthSmall = 80;
  static const double buttonWidthMedium = 120;
  static const double buttonWidthLarge = 160;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconSizeXSmall = 12;
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;
  static const double iconSizeXXLarge = 64;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double borderRadiusSmall = 4;
  static const double borderRadiusMedium = 8;
  static const double borderRadiusLarge = 12;
  static const double borderRadiusXLarge = 16;
  static const double borderRadiusXXLarge = 20;
  static const double borderRadiusCircle = 50;

  // ============================================================================
  // CARD & CONTAINER SIZES
  // ============================================================================

  static const double cardElevation = 2;
  static const double cardElevationHigh = 4;

  static const double containerMinHeight = 100;
  static const double containerMaxHeight = 500;

  // ============================================================================
  // ASPECT RATIOS
  // ============================================================================

  static const double aspectRatioSquare = 1.0;
  static const double aspectRatioPortrait = 0.75;
  static const double aspectRatioLandscape = 1.33;
  static const double aspectRatioWidescreen = 1.78;

  // ============================================================================
  // CHART SIZES
  // ============================================================================

  static const double chartHeightSmall = 150;
  static const double chartHeightMedium = 250;
  static const double chartHeightLarge = 350;

  static const double chartWidthSmall = 200;
  static const double chartWidthMedium = 300;
  static const double chartWidthLarge = 400;

  // ============================================================================
  // GRID SIZES
  // ============================================================================

  static const int gridCrossAxisCountPhone = 1;
  static const int gridCrossAxisCountTablet = 2;
  static const int gridCrossAxisCountDesktop = 3;

  static const double gridSpacingSmall = 8;
  static const double gridSpacingMedium = 12;
  static const double gridSpacingLarge = 16;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // PHONE SPECIFIC
  // ============================================================================

  static const double phoneMaxWidth = 480;
  static const double phoneContentPadding = 12;
  static const double phoneCardHeight = 120;
  static const double phoneChartHeight = 200;

  // ============================================================================
  // TABLET SPECIFIC
  // ============================================================================

  static const double tabletMaxWidth = 900;
  static const double tabletContentPadding = 16;
  static const double tabletCardHeight = 140;
  static const double tabletChartHeight = 280;

  // ============================================================================
  // DESKTOP SPECIFIC
  // ============================================================================

  static const double desktopMaxWidth = 1440;
  static const double desktopContentPadding = 20;
  static const double desktopCardHeight = 160;
  static const double desktopChartHeight = 350;

  // ============================================================================
  // MODAL & DIALOG SIZES
  // ============================================================================

  static const double modalWidthPhone = 0.9; // 90% of screen
  static const double modalWidthTablet = 0.7; // 70% of screen
  static const double modalWidthDesktop = 0.5; // 50% of screen

  static const double dialogMaxWidth = 600;
  static const double dialogMinWidth = 300;

  // ============================================================================
  // BOTTOM SHEET SIZES
  // ============================================================================

  static const double bottomSheetHeightPhone = 0.8; // 80% of screen
  static const double bottomSheetHeightTablet = 0.6; // 60% of screen
  static const double bottomSheetHeightDesktop = 0.5; // 50% of screen

  // ============================================================================
  // DRAWER SIZES
  // ============================================================================

  static const double drawerWidth = 280;
  static const double drawerWidthTablet = 320;

  // ============================================================================
  // NAVIGATION SIZES
  // ============================================================================

  static const double navigationRailWidth = 80;
  static const double navigationBarHeight = 56;
  static const double navigationBarHeightLarge = 64;

  // ============================================================================
  // SPACING HELPERS
  // ============================================================================

  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 12;
  static const double spacingLarge = 16;
  static const double spacingXLarge = 20;
  static const double spacingXXLarge = 24;

  // ============================================================================
  // DIVIDER SIZES
  // ============================================================================

  static const double dividerThickness = 1;
  static const double dividerThicknessHeavy = 2;

  // ============================================================================
  // SHADOW SIZES
  // ============================================================================

  static const double shadowBlurRadius = 8;
  static const double shadowSpreadRadius = 0;
  static const double shadowOffsetX = 0;
  static const double shadowOffsetY = 2;

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================

  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.8;
  static const double opacityActive = 1.0;

  // ============================================================================
  // Z-INDEX / ELEVATION
  // ============================================================================

  static const double elevationLow = 1;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;
  static const double elevationVeryHigh = 16;
}
