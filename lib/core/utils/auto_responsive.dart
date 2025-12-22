import 'package:flutter/material.dart';

/// Auto Responsive System
/// Automatically detects device size and applies proportional scaling
/// Width: (widget_size / 360) * device_width (Professor's formula)
/// Height: Conservative scaling to prevent UI stretching
/// Reference: Google Pixel 9 (360px x 800px)
class AutoResponsive {
  // Reference device dimensions
  static const double _referenceWidth = 360.0;
  static const double _referenceHeight = 800.0; // Conservative height baseline

  // Maximum height scale factor to prevent over-stretching
  static const double _maxHeightScale = 1.3;

  // Cached device info for performance
  static Size? _cachedDeviceSize;
  static double? _cachedWidthScale;
  static double? _cachedHeightScale;

  /// Initialize auto responsive system (call once in main.dart)
  static void initialize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _cachedDeviceSize = size;

    // Width uses professor's formula: (widget_size / 360) * device_width
    _cachedWidthScale = size.width / _referenceWidth;

    // Height uses conservative scaling to prevent UI stretching
    final rawHeightScale = size.height / _referenceHeight;
    _cachedHeightScale = rawHeightScale.clamp(0.8, _maxHeightScale);

    debugPrint('🎯 AutoResponsive initialized (Conservative Height):');
    debugPrint('   Device: ${size.width.toInt()}x${size.height.toInt()}');
    debugPrint(
      '   Reference: ${_referenceWidth.toInt()}x${_referenceHeight.toInt()}',
    );
    debugPrint(
      '   Scale: W=${_cachedWidthScale!.toStringAsFixed(2)}x, H=${_cachedHeightScale!.toStringAsFixed(2)}x (clamped)',
    );
    debugPrint('   Raw Height Scale: ${rawHeightScale.toStringAsFixed(2)}x');
  }

  /// Auto-scale width (no context needed after initialization)
  static double w(double width) {
    assert(
      _cachedWidthScale != null,
      'AutoResponsive not initialized! Call AutoResponsive.initialize(context) first.',
    );
    return width * _cachedWidthScale!;
  }

  /// Auto-scale height (no context needed after initialization)
  static double h(double height) {
    assert(
      _cachedHeightScale != null,
      'AutoResponsive not initialized! Call AutoResponsive.initialize(context) first.',
    );
    return height * _cachedHeightScale!;
  }

  /// Auto-scale font size (based on width scaling)
  static double sp(double fontSize) {
    return w(fontSize);
  }

  /// Auto-scale radius
  static double r(double radius) {
    return w(radius);
  }

  /// Auto-scale padding (all sides)
  static EdgeInsets p(double padding) {
    return EdgeInsets.all(w(padding));
  }

  /// Auto-scale horizontal padding
  static EdgeInsets pH(double horizontal) {
    return EdgeInsets.symmetric(horizontal: w(horizontal));
  }

  /// Auto-scale vertical padding (conservative)
  static EdgeInsets pV(double vertical) {
    return EdgeInsets.symmetric(vertical: h(vertical));
  }

  /// Compact vertical padding (50% of normal height scaling)
  static EdgeInsets pVCompact(double vertical) {
    return EdgeInsets.symmetric(vertical: h(vertical) * 0.5);
  }

  /// Auto-scale custom padding
  static EdgeInsets pCustom(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.only(
      left: w(left),
      top: h(top),
      right: w(right),
      bottom: h(bottom),
    );
  }

  /// Compact custom padding (50% height scaling)
  static EdgeInsets pCustomCompact(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.only(
      left: w(left),
      top: h(top) * 0.5,
      right: w(right),
      bottom: h(bottom) * 0.5,
    );
  }

  /// Auto-scale horizontal spacing widget
  static Widget hSpace(double width) {
    return SizedBox(width: w(width));
  }

  /// Auto-scale vertical spacing widget
  static Widget vSpace(double height) {
    return SizedBox(height: h(height));
  }

  /// Compact vertical spacing (50% of normal height scaling)
  static Widget vSpaceCompact(double height) {
    return SizedBox(height: h(height) * 0.5);
  }

  /// Get device info for debugging
  static String get deviceInfo {
    if (_cachedDeviceSize == null) return 'Not initialized';
    final rawHeightScale = _cachedDeviceSize!.height / _referenceHeight;
    return '''
Device: ${_cachedDeviceSize!.width.toInt()}x${_cachedDeviceSize!.height.toInt()}
Reference: ${_referenceWidth.toInt()}x${_referenceHeight.toInt()}
Scale: W=${_cachedWidthScale!.toStringAsFixed(2)}x, H=${_cachedHeightScale!.toStringAsFixed(2)}x (clamped)
Raw Height Scale: ${rawHeightScale.toStringAsFixed(2)}x
Max Height Scale: $_maxHeightScale
Status: Auto-responsive active ✅
''';
  }

  /// Check if system is initialized
  static bool get isInitialized => _cachedWidthScale != null;

  /// Get current scale factors
  static Map<String, double> get scaleFactors => {
    'widthScale': _cachedWidthScale ?? 1.0,
    'heightScale': _cachedHeightScale ?? 1.0,
    'deviceWidth': _cachedDeviceSize?.width ?? _referenceWidth,
    'deviceHeight': _cachedDeviceSize?.height ?? _referenceHeight,
    'referenceWidth': _referenceWidth,
    'referenceHeight': _referenceHeight,
    'maxHeightScale': _maxHeightScale,
  };
}

/// Extension methods for even easier usage
extension AutoResponsiveExtensions on num {
  /// Auto-scale width: 200.aw → scaled width
  double get aw => AutoResponsive.w(toDouble());

  /// Auto-scale height: 100.ah → scaled height
  double get ah => AutoResponsive.h(toDouble());

  /// Compact height (50% height scaling): 100.ahCompact → scaled height * 0.5
  double get ahCompact => AutoResponsive.h(toDouble()) * 0.5;

  /// Auto-scale font size: 16.asp → scaled font size
  double get asp => AutoResponsive.sp(toDouble());

  /// Auto-scale radius: 8.ar → scaled radius
  double get ar => AutoResponsive.r(toDouble());
}

/// Auto-responsive widgets that work without context
class AR {
  /// Horizontal spacing
  static Widget w(double width) => AutoResponsive.hSpace(width);

  /// Vertical spacing
  static Widget h(double height) => AutoResponsive.vSpace(height);

  /// Compact vertical spacing (50% height scaling)
  static Widget hCompact(double height) => AutoResponsive.vSpaceCompact(height);

  /// Padding (all sides)
  static EdgeInsets p(double padding) => AutoResponsive.p(padding);

  /// Horizontal padding
  static EdgeInsets pH(double horizontal) => AutoResponsive.pH(horizontal);

  /// Vertical padding
  static EdgeInsets pV(double vertical) => AutoResponsive.pV(vertical);

  /// Compact vertical padding (50% height scaling)
  static EdgeInsets pVCompact(double vertical) =>
      AutoResponsive.pVCompact(vertical);

  /// Custom padding
  static EdgeInsets pCustom(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return AutoResponsive.pCustom(left, top, right, bottom);
  }

  /// Compact custom padding (50% height scaling)
  static EdgeInsets pCustomCompact(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return AutoResponsive.pCustomCompact(left, top, right, bottom);
  }
}

/// Auto-responsive text widget
class AText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const AText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: fontSize.asp, // Auto-scaled font size
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Auto-responsive container widget
class AContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? borderRadius;

  const AContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.aw, // Auto-scaled width
      height: height?.ah, // Auto-scaled height
      padding: padding != null
          ? EdgeInsets.only(
              left: padding!.left.aw,
              top: padding!.top.ah,
              right: padding!.right.aw,
              bottom: padding!.bottom.ah,
            )
          : null,
      margin: margin != null
          ? EdgeInsets.only(
              left: margin!.left.aw,
              top: margin!.top.ah,
              right: margin!.right.aw,
              bottom: margin!.bottom.ah,
            )
          : null,
      decoration:
          decoration ??
          (color != null || borderRadius != null
              ? BoxDecoration(
                  color: color,
                  borderRadius: borderRadius != null
                      ? BorderRadius.circular(borderRadius!.ar)
                      : null,
                )
              : null),
      child: child,
    );
  }
}
