import 'package:flutter/material.dart';
import '../../../core/utils/proportional_extensions.dart';
import '../../../config/constants/proportional_constants.dart';

/// Proportional Text Widget
/// Automatically scales font size based on device
class PText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const PText(
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

  // Predefined text styles
  const PText.small(
    this.text, {
    super.key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : fontSize = ProportionalConstants.fontSizeSmall;

  const PText.medium(
    this.text, {
    super.key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : fontSize = ProportionalConstants.fontSizeMedium;

  const PText.large(
    this.text, {
    super.key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : fontSize = ProportionalConstants.fontSizeLarge;

  const PText.title(
    this.text, {
    super.key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : fontSize = ProportionalConstants.fontSizeTitle;

  const PText.heading(
    this.text, {
    super.key,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  }) : fontSize = ProportionalConstants.fontSizeHeading;

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = fontSize.sp(context);

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: scaledFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Proportional Container Widget
class PContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? borderRadius;

  const PContainer({
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
      width: width?.w(context),
      height: height?.h(context),
      padding: padding?.scale(context),
      margin: margin?.scale(context),
      decoration:
          decoration ??
          (color != null || borderRadius != null
              ? BoxDecoration(
                  color: color,
                  borderRadius: borderRadius != null
                      ? BorderRadius.circular(borderRadius!.r(context))
                      : null,
                )
              : null),
      child: child,
    );
  }
}

/// Proportional Button Widget
class PButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final bool isLoading;
  final IconData? icon;

  const PButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  });

  // Predefined button sizes
  const PButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  }) : width = ProportionalConstants.buttonWidthSmall,
       height = ProportionalConstants.buttonHeightSmall;

  const PButton.medium({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  }) : width = ProportionalConstants.buttonWidthMedium,
       height = ProportionalConstants.buttonHeightMedium;

  const PButton.large({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  }) : width = ProportionalConstants.buttonWidthLarge,
       height = ProportionalConstants.buttonHeightLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.w(context),
      height: height?.h(context),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: ProportionalConstants.iconSizeSmall.w(context),
                height: ProportionalConstants.iconSizeSmall.h(context),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null
                  ? Icon(
                      icon,
                      size: ProportionalConstants.iconSizeSmall.w(context),
                    )
                  : const SizedBox.shrink()),
        label: PText(
          text,
          fontSize: fontSize ?? ProportionalConstants.fontSizeMedium,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              (borderRadius ?? ProportionalConstants.radiusMedium).r(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Proportional Card Widget
class PCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;

  const PCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w(context),
      height: height?.h(context),
      margin: margin?.scale(context),
      child: Card(
        color: color,
        elevation: elevation ?? ProportionalConstants.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            (borderRadius ?? ProportionalConstants.radiusMedium).r(context),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            (borderRadius ?? ProportionalConstants.radiusMedium).r(context),
          ),
          child: Padding(
            padding:
                (padding ??
                        const EdgeInsets.all(
                          ProportionalConstants.cardPaddingMedium,
                        ))
                    .scale(context),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Proportional Icon Widget
class PIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const PIcon(this.icon, {super.key, this.size, this.color});

  // Predefined icon sizes
  const PIcon.small(this.icon, {super.key, this.color})
    : size = ProportionalConstants.iconSizeSmall;

  const PIcon.medium(this.icon, {super.key, this.color})
    : size = ProportionalConstants.iconSizeMedium;

  const PIcon.large(this.icon, {super.key, this.color})
    : size = ProportionalConstants.iconSizeLarge;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: (size ?? ProportionalConstants.iconSizeMedium).w(context),
      color: color,
    );
  }
}

/// Proportional Spacing Widgets
class PSpacing {
  /// Horizontal spacing
  static Widget horizontal(BuildContext context, double width) {
    return SizedBox(width: width.w(context));
  }

  /// Vertical spacing
  static Widget vertical(BuildContext context, double height) {
    return SizedBox(height: height.h(context));
  }

  /// Predefined spacing
  static Widget get xSmall => Builder(
    builder: (context) =>
        SizedBox(height: ProportionalConstants.spacingXSmall.h(context)),
  );

  static Widget get small => Builder(
    builder: (context) =>
        SizedBox(height: ProportionalConstants.spacingSmall.h(context)),
  );

  static Widget get medium => Builder(
    builder: (context) =>
        SizedBox(height: ProportionalConstants.spacingMedium.h(context)),
  );

  static Widget get large => Builder(
    builder: (context) =>
        SizedBox(height: ProportionalConstants.spacingLarge.h(context)),
  );

  static Widget get xLarge => Builder(
    builder: (context) =>
        SizedBox(height: ProportionalConstants.spacingXLarge.h(context)),
  );
}
