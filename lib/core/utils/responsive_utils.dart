import 'package:flutter/material.dart';

/// Device type enumeration
enum DeviceType { phone, tablet, desktop }

/// Responsive utilities for handling different screen sizes
class ResponsiveUtils {
  /// Get device width
  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get device height
  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Detect device type based on width
  static DeviceType getDeviceType(BuildContext context) {
    final width = getDeviceWidth(context);
    if (width < 600) {
      return DeviceType.phone;
    } else if (width < 1000) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get device type name
  static String getDeviceTypeName(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.phone:
        return 'Phone';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop';
    }
  }

  /// Check if device is phone
  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Check if device is in landscape
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get responsive width based on device type
  static double getResponsiveWidth(
    BuildContext context, {
    required double phoneWidth,
    required double tabletWidth,
    required double desktopWidth,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phoneWidth;
      case DeviceType.tablet:
        return tabletWidth;
      case DeviceType.desktop:
        return desktopWidth;
    }
  }

  /// Get responsive height based on device type
  static double getResponsiveHeight(
    BuildContext context, {
    required double phoneHeight,
    required double tabletHeight,
    required double desktopHeight,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phoneHeight;
      case DeviceType.tablet:
        return tabletHeight;
      case DeviceType.desktop:
        return desktopHeight;
    }
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive padding with custom values
  static EdgeInsets getResponsivePaddingCustom(
    BuildContext context, {
    required double phoneValue,
    required double tabletValue,
    required double desktopValue,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return EdgeInsets.all(phoneValue);
      case DeviceType.tablet:
        return EdgeInsets.all(tabletValue);
      case DeviceType.desktop:
        return EdgeInsets.all(desktopValue);
    }
  }

  /// Get responsive font size based on device type
  static double getResponsiveFontSize(
    BuildContext context, {
    required double phoneSize,
    required double tabletSize,
    required double desktopSize,
  }) {
    final deviceType = getDeviceType(context);
    final width = getDeviceWidth(context);

    // For very small phones (< 360px), scale up slightly
    if (width < 360 && deviceType == DeviceType.phone) {
      return phoneSize * 1.1;
    }

    switch (deviceType) {
      case DeviceType.phone:
        return phoneSize;
      case DeviceType.tablet:
        return tabletSize;
      case DeviceType.desktop:
        return desktopSize;
    }
  }

  /// Get percentage-based width
  static double getPercentageWidth(BuildContext context, double percentage) {
    return getDeviceWidth(context) * (percentage / 100);
  }

  /// Get percentage-based height
  static double getPercentageHeight(BuildContext context, double percentage) {
    return getDeviceHeight(context) * (percentage / 100);
  }

  /// Get width based on aspect ratio
  static double getAspectRatioWidth(BuildContext context, double aspectRatio) {
    final width = getDeviceWidth(context);
    return width / aspectRatio;
  }

  /// Get height based on aspect ratio
  static double getAspectRatioHeight(BuildContext context, double aspectRatio) {
    final height = getDeviceHeight(context);
    return height / aspectRatio;
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Get responsive grid cross axis count with custom values
  static int getGridCrossAxisCountCustom(
    BuildContext context, {
    required int phoneCount,
    required int tabletCount,
    required int desktopCount,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phoneCount;
      case DeviceType.tablet:
        return tabletCount;
      case DeviceType.desktop:
        return desktopCount;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 24;
      case DeviceType.tablet:
        return 28;
      case DeviceType.desktop:
        return 32;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 44;
      case DeviceType.tablet:
        return 48;
      case DeviceType.desktop:
        return 52;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 8;
      case DeviceType.tablet:
        return 12;
      case DeviceType.desktop:
        return 16;
    }
  }

  /// Get max width for content (useful for desktop)
  static double getMaxContentWidth(BuildContext context) {
    final width = getDeviceWidth(context);
    if (width > 1200) {
      return 1200;
    }
    return width;
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double phoneSpacing,
    required double tabletSpacing,
    required double desktopSpacing,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phoneSpacing;
      case DeviceType.tablet:
        return tabletSpacing;
      case DeviceType.desktop:
        return desktopSpacing;
    }
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard height, etc)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}
