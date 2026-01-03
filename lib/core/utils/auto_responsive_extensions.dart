import 'package:flutter/material.dart';
import '../../config/constants/responsive_constants.dart';

/// Auto Responsive Extensions
/// Based on formula: (widget_size / 360) * device_width
/// Reference Device: Google Pixel 9 (360px x 800px)
extension AutoResponsiveExtensions on num {
  /// Auto-scale width: 200.aw(context) → scaled width
  double aw(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return ResponsiveConstants.getResponsiveWidth(deviceWidth, toDouble());
  }

  /// Auto-scale height: 100.ah(context) → scaled height
  double ah(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return ResponsiveConstants.getResponsiveHeight(deviceHeight, toDouble());
  }

  /// Auto-scale radius: 8.ar(context) → scaled radius
  double ar(BuildContext context) {
    return aw(context); // Radius based on width scaling
  }

  /// Auto-scale font size: 16.asp(context) → scaled font size
  double asp(BuildContext context) {
    return aw(context); // Font size based on width scaling
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
