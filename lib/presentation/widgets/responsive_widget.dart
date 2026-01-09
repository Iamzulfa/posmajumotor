import 'package:flutter/material.dart';
import 'package:posfelix/core/utils/responsive_utils.dart';

/// A widget that builds different layouts based on device type
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;

  const ResponsiveWidget({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// A widget that provides responsive layout with phone, tablet, and desktop variants
class ResponsiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;

  const ResponsiveLayout({
    required this.phoneLayout,
    this.tabletLayout,
    this.desktopLayout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.phone:
            return phoneLayout;
          case DeviceType.tablet:
            return tabletLayout ?? phoneLayout;
          case DeviceType.desktop:
            return desktopLayout ?? tabletLayout ?? phoneLayout;
        }
      },
    );
  }
}

/// A widget that constrains content to a maximum width (useful for desktop)
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    final contentPadding =
        padding ?? ResponsiveUtils.getResponsivePadding(context);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        padding: contentPadding,
        child: child,
      ),
    );
  }
}

/// A widget that builds a responsive grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? spacing;
  final double? runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final WrapAlignment mainAxisAlignment;

  const ResponsiveGrid({
    required this.children,
    this.crossAxisCount,
    this.spacing,
    this.runSpacing,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.mainAxisAlignment = WrapAlignment.start,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final count =
        crossAxisCount ?? ResponsiveUtils.getGridCrossAxisCount(context);
    final itemSpacing = spacing ?? 12;
    final itemRunSpacing = runSpacing ?? 12;

    return Wrap(
      spacing: itemSpacing,
      runSpacing: itemRunSpacing,
      crossAxisAlignment: crossAxisAlignment,
      alignment: mainAxisAlignment,
      children: children.map((child) {
        final itemWidth =
            (ResponsiveUtils.getDeviceWidth(context) -
                (itemSpacing * (count - 1))) /
            count;
        return SizedBox(width: itemWidth, child: child);
      }).toList(),
    );
  }
}

/// A widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? phoneValue;
  final double? tabletValue;
  final double? desktopValue;

  const ResponsivePadding({
    required this.child,
    this.phoneValue,
    this.tabletValue,
    this.desktopValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: phoneValue ?? 12,
      tabletValue: tabletValue ?? 16,
      desktopValue: desktopValue ?? 20,
    );

    return Padding(padding: padding, child: child);
  }
}

/// A widget that provides responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? phoneSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    this.phoneSize,
    this.tabletSize,
    this.desktopSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: phoneSize ?? 14,
      tabletSize: tabletSize ?? 16,
      desktopSize: desktopSize ?? 18,
    );

    final textStyle = (style ?? const TextStyle()).copyWith(fontSize: fontSize);

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A widget that provides responsive spacing
class ResponsiveSpacing extends StatelessWidget {
  final double? phoneHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? width;

  const ResponsiveSpacing({
    this.phoneHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: phoneHeight ?? 8,
      tabletSpacing: tabletHeight ?? 12,
      desktopSpacing: desktopHeight ?? 16,
    );

    return SizedBox(height: height, width: width);
  }
}

/// A widget that provides responsive divider
class ResponsiveDivider extends StatelessWidget {
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const ResponsiveDivider({
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness ?? 1,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

/// A widget that provides responsive button
class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final IconData? icon;

  const ResponsiveButton({
    required this.label,
    required this.onPressed,
    this.style,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final isSmallScreen = ResponsiveUtils.isPhone(context);

    return SizedBox(
      height: buttonHeight,
      width: isSmallScreen ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : SizedBox.shrink()),
        label: Text(label),
        style: style,
      ),
    );
  }
}

/// A widget that provides responsive card
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? color;
  final ShapeBorder? shape;
  final VoidCallback? onTap;

  const ResponsiveCard({
    required this.child,
    this.padding,
    this.elevation,
    this.color,
    this.shape,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding =
        padding ?? ResponsiveUtils.getResponsivePadding(context);

    return Card(
      elevation: elevation ?? 2,
      color: color,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: cardPadding, child: child),
      ),
    );
  }
}
