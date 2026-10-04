import 'package:flutter/material.dart';
import '../app/responsive/responsive_utils.dart';
import '../app/responsive/adaptive_layout.dart';
import '../app/theme/app_theme.dart' as theme;

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool constrainWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.constrainWidth = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveUtils.responsivePadding(context);
    final maxWidth = constrainWidth ? ResponsiveUtils.getMaxWidth(context) : double.infinity;

    return Container(
      color: backgroundColor,
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;

  const ResponsiveScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
          ),
        ),
        centerTitle: ResponsiveUtils.isMobile(context),
        automaticallyImplyLeading: showBackButton,
        leading: onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              )
            : null,
        actions: actions,
      ),
      body: ResponsiveWrapper(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final GestureTapCallback? onTap;
  final Color? color;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveUtils.responsiveCardPadding(context);
    final effectiveElevation = elevation ?? (ResponsiveUtils.isDesktop(context) ? 6 : 3);

    return Card(
      elevation: effectiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveBorderRadius(context, 16),
        ),
      ),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveBorderRadius(context, 16),
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveGrid(
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style?.copyWith(
      fontSize: style?.fontSize != null
          ? ResponsiveUtils.responsiveFontSize(context, style!.fontSize!)
          : null,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final bool fullWidth;

  const ResponsiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveUtils.responsiveButtonHeight(context);

    final button = SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: AdaptiveButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isPrimary: isPrimary,
        isLoading: isLoading,
      ),
    );

    if (fullWidth) {
      return button;
    }

    return button;
  }
}

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ResponsiveIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size != null
        ? ResponsiveUtils.responsiveIconSize(context, size!)
        : ResponsiveUtils.responsiveIconSize(context, 24);

    return Icon(
      icon,
      size: effectiveSize,
      color: color,
    );
  }
}

class ResponsiveSpace extends StatelessWidget {
  final double height;
  final double width;

  const ResponsiveSpace({
    super.key,
    this.height = 16,
    this.width = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtils.responsiveSpacing(context, height),
      width: ResponsiveUtils.responsiveSpacing(context, width),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveRow(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      spacing: spacing,
      children: children,
    );
  }
}
