import 'package:flutter/material.dart';
import 'proportional_responsive.dart';

/// Extension methods untuk memudahkan penggunaan proportional scaling
extension ProportionalExtensions on num {
  /// Scale width: 200.w(context) -> scaled width
  double w(BuildContext context) {
    return ProportionalResponsive.scaleWidth(context, toDouble());
  }

  /// Scale height: 100.h(context) -> scaled height
  double h(BuildContext context) {
    return ProportionalResponsive.scaleHeight(context, toDouble());
  }

  /// Scale font size: 16.sp(context) -> scaled font size
  double sp(BuildContext context) {
    return ProportionalResponsive.scaleFontSize(context, toDouble());
  }

  /// Scale radius: 8.r(context) -> scaled radius
  double r(BuildContext context) {
    return ProportionalResponsive.scaleWidth(context, toDouble());
  }
}

/// Extension for EdgeInsets
extension EdgeInsetsExtension on EdgeInsets {
  /// Scale EdgeInsets proportionally
  EdgeInsets scale(BuildContext context) {
    return ProportionalResponsive.scalePadding(context, this);
  }
}

/// Extension for Size
extension SizeExtension on Size {
  /// Scale Size proportionally
  Size scale(BuildContext context) {
    return ProportionalResponsive.scaleSize(context, this);
  }
}

/// Extension for BorderRadius
extension BorderRadiusExtension on BorderRadius {
  /// Scale BorderRadius proportionally
  BorderRadius scale(BuildContext context) {
    // Ambil radius dari topLeft sebagai referensi
    final radius = topLeft.x;
    return ProportionalResponsive.scaleBorderRadius(context, radius);
  }
}

/// Utility widgets untuk spacing
class ProportionalSpacing {
  /// Horizontal spacing
  static Widget horizontalSpace(BuildContext context, double width) {
    return ProportionalResponsive.scaledWidthBox(context, width);
  }

  /// Vertical spacing
  static Widget verticalSpace(BuildContext context, double height) {
    return ProportionalResponsive.scaledHeightBox(context, height);
  }

  /// Both dimensions spacing
  static Widget space(BuildContext context, double width, double height) {
    return ProportionalResponsive.scaledBox(context, width, height);
  }
}

/// Shorthand untuk spacing
class PS {
  /// Horizontal space: PS.w(context, 20)
  static Widget w(BuildContext context, double width) {
    return ProportionalSpacing.horizontalSpace(context, width);
  }

  /// Vertical space: PS.h(context, 10)
  static Widget h(BuildContext context, double height) {
    return ProportionalSpacing.verticalSpace(context, height);
  }

  /// Both dimensions: PS.box(context, 20, 10)
  static Widget box(BuildContext context, double width, double height) {
    return ProportionalSpacing.space(context, width, height);
  }
}
