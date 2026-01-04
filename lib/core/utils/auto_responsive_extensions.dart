import 'package:flutter/material.dart';
import '../../config/constants/responsive_constants.dart';

/// Auto Responsive Extensions
/// Based on formula: (widget_size / 360) * device_width with landscape and device type constraints
/// Reference Device: Google Pixel 9 (360px x 800px)
extension AutoResponsiveExtensions on num {
  /// Auto-scale width: 200.aw(context) → scaled width
  double aw(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Base scaling
    double scaledValue = ResponsiveConstants.getResponsiveWidth(
      deviceWidth,
      toDouble(),
    );

    // Apply landscape constraints to prevent excessive scaling
    if (isLandscape) {
      // In landscape, limit scaling to prevent UI elements from becoming too large
      final maxScale = toDouble() * 1.3; // Max 30% increase from original size
      scaledValue = scaledValue > maxScale ? maxScale : scaledValue;
    }

    // Apply device type constraints
    if (deviceWidth > 600) {
      // Tablet and desktop
      // Limit scaling on larger devices to prevent massive UI elements
      final maxScale = toDouble() * (deviceWidth > 1000 ? 1.5 : 1.4);
      scaledValue = scaledValue > maxScale ? maxScale : scaledValue;
    }

    return scaledValue;
  }

  /// Auto-scale height: 100.ah(context) → scaled height
  double ah(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceHeight = mediaQuery.size.height;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Base scaling
    double scaledValue = ResponsiveConstants.getResponsiveHeight(
      deviceHeight,
      toDouble(),
    );

    // In landscape, be more conservative with height scaling
    if (isLandscape) {
      // Use width-based scaling for height in landscape to maintain proportions
      final deviceWidth = mediaQuery.size.width;
      scaledValue =
          ResponsiveConstants.getResponsiveWidth(deviceWidth, toDouble()) * 0.8;
    }

    return scaledValue;
  }

  /// Auto-scale radius: 8.ar(context) → scaled radius
  double ar(BuildContext context) {
    // Use more conservative scaling for radius
    final scaledWidth = aw(context);
    return scaledWidth > toDouble() * 1.2 ? toDouble() * 1.2 : scaledWidth;
  }

  /// Auto-scale font size: 16.asp(context) → scaled font size
  double asp(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Base scaling
    double scaledValue = ResponsiveConstants.getResponsiveWidth(
      deviceWidth,
      toDouble(),
    );

    // Font size constraints to maintain readability
    final minSize = toDouble() * 0.8; // Never go below 80% of original
    final maxSize =
        toDouble() * (isLandscape ? 1.2 : 1.4); // Conservative scaling

    if (scaledValue < minSize) scaledValue = minSize;
    if (scaledValue > maxSize) scaledValue = maxSize;

    return scaledValue;
  }
}

/// Auto Responsive Widgets
class AR {
  /// Horizontal spacing: AR.w(context, 16)
  static Widget w(BuildContext context, double width) {
    return SizedBox(width: width.aw(context));
  }

  /// Vertical spacing: AR.h(context, 12)
  static Widget h(BuildContext context, double height) {
    return SizedBox(height: height.ah(context));
  }

  /// Padding (all sides): AR.p(context, 16)
  static EdgeInsets p(BuildContext context, double padding) {
    return EdgeInsets.all(padding.aw(context));
  }

  /// Horizontal padding: AR.pH(context, 16)
  static EdgeInsets pH(BuildContext context, double horizontal) {
    return EdgeInsets.symmetric(horizontal: horizontal.aw(context));
  }

  /// Vertical padding: AR.pV(context, 12)
  static EdgeInsets pV(BuildContext context, double vertical) {
    return EdgeInsets.symmetric(vertical: vertical.ah(context));
  }
}

/// Auto Responsive Text Widget
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
        fontSize: fontSize.asp(context), // Auto-scaled font size
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
