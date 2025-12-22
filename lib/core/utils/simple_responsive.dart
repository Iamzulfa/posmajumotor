import 'package:flutter/material.dart';

/// Simple Responsive Helper
/// Based on formula: (widget_size / 360) * device_width
/// Reference: Google Pixel 9 (360px width)
class SR {
  // Reference device width (Google Pixel 9)
  static const double _referenceWidth = 360.0;
  static const double _referenceHeight = 800.0;

  /// Scale width: SR.w(context, 200) -> scaled width
  static double w(BuildContext context, double width) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return (width / _referenceWidth) * deviceWidth;
  }

  /// Scale height: SR.h(context, 100) -> scaled height
  static double h(BuildContext context, double height) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return (height / _referenceHeight) * deviceHeight;
  }

  /// Scale font size: SR.sp(context, 16) -> scaled font size
  static double sp(BuildContext context, double fontSize) {
    return w(context, fontSize); // Font scaling based on width
  }

  /// Scale radius: SR.r(context, 8) -> scaled radius
  static double r(BuildContext context, double radius) {
    return w(context, radius);
  }

  /// Scale padding: SR.p(context, 16) -> scaled padding
  static EdgeInsets p(BuildContext context, double padding) {
    return EdgeInsets.all(w(context, padding));
  }

  /// Scale symmetric padding: SR.pH(context, 16) -> horizontal padding
  static EdgeInsets pH(BuildContext context, double horizontal) {
    return EdgeInsets.symmetric(horizontal: w(context, horizontal));
  }

  /// Scale symmetric padding: SR.pV(context, 12) -> vertical padding
  static EdgeInsets pV(BuildContext context, double vertical) {
    return EdgeInsets.symmetric(vertical: h(context, vertical));
  }

  /// Scale custom padding: SR.pCustom(context, 16, 12, 16, 12)
  static EdgeInsets pCustom(
    BuildContext context,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.only(
      left: w(context, left),
      top: h(context, top),
      right: w(context, right),
      bottom: h(context, bottom),
    );
  }

  /// Horizontal spacing: SR.hSpace(context, 16)
  static Widget hSpace(BuildContext context, double width) {
    return SizedBox(width: w(context, width));
  }

  /// Vertical spacing: SR.vSpace(context, 12)
  static Widget vSpace(BuildContext context, double height) {
    return SizedBox(height: h(context, height));
  }

  /// Get device info for debugging
  static String deviceInfo(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final widthScale = deviceWidth / _referenceWidth;
    final heightScale = deviceHeight / _referenceHeight;

    return '''
Device: ${deviceWidth.toInt()}x${deviceHeight.toInt()}
Reference: ${_referenceWidth.toInt()}x${_referenceHeight.toInt()}
Scale: W=${widthScale.toStringAsFixed(2)}x, H=${heightScale.toStringAsFixed(2)}x
''';
  }
}
