import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    // Use appropriate layout based on screen size
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Use appropriate columns based on screen size
    final columns = ResponsiveUtils.responsiveValue(
      context: context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 4,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      padding: padding ?? ResponsiveUtils.responsivePadding(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final double? maxWidth;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.maxWidth,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxWidth(context);
    final effectivePadding = padding ?? ResponsiveUtils.responsivePadding(context);

    return Container(
      width: width,
      height: height,
      color: color,
      decoration: decoration,
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? color;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.shape,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveUtils.responsiveCardPadding(context);
    final effectiveElevation = elevation ?? (ResponsiveUtils.isDesktop(context) ? 8 : 4);
    final effectiveShape = shape ?? RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        ResponsiveUtils.responsiveBorderRadius(context, 16),
      ),
    );

    return Card(
      elevation: effectiveElevation,
      shape: effectiveShape,
      color: color,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

class AdaptiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const AdaptiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop-only: always use Row layout
    final effectiveSpacing = ResponsiveUtils.responsiveSpacing(context, spacing);

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, effectiveSpacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing, height: spacing));
      }
    }
    return spacedChildren;
  }
}

class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;

  const AdaptiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveUtils.responsiveButtonHeight(context);
    final fontSize = ResponsiveUtils.responsiveFontSize(context, 16);

    if (isPrimary) {
      return SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.responsiveSpacing(context, 32),
              vertical: ResponsiveUtils.responsiveSpacing(context, 16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: fontSize),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveSpacing(context, 32),
            vertical: ResponsiveUtils.responsiveSpacing(context, 16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }
}
