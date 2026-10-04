import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Desktop-only configuration - optimized for laptop/desktop
  static const double desktopScreen = 800; // Lower threshold for desktop-only

  /// Always return true for desktop (laptop/desktop only)
  static bool isMobile(BuildContext context) {
    return false; // Disabled - desktop only
  }

  /// Always return false for tablet (laptop/desktop only)
  static bool isTablet(BuildContext context) {
    return false; // Disabled - desktop only
  }

  /// Always return true for desktop (laptop/desktop only)
  static bool isDesktop(BuildContext context) {
    return true; // Always desktop
  }

  /// Get responsive value based on screen size (desktop only)
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    // Always use desktop value if available, otherwise fallback to mobile
    return desktop ?? mobile;
  }

  /// Get responsive padding (desktop optimized)
  static EdgeInsets responsivePadding(BuildContext context) {
    return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
  }

  /// Get responsive card padding (desktop optimized)
  static EdgeInsets responsiveCardPadding(BuildContext context) {
    return const EdgeInsets.all(24);
  }

  /// Get responsive grid columns (desktop optimized)
  static int getGridColumns(BuildContext context) {
    return 4;
  }

  /// Get responsive font size (desktop optimized)
  static double responsiveFontSize(BuildContext context, double baseSize) {
    return baseSize * 1.2;
  }

  /// Get responsive icon size (desktop optimized)
  static double responsiveIconSize(BuildContext context, double baseSize) {
    return baseSize * 1.3;
  }

  /// Get responsive spacing (desktop optimized)
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return baseSpacing * 1.5;
  }

  /// Get responsive container max width (desktop optimized)
  static double getMaxWidth(BuildContext context) {
    return 1400;
  }

  /// Get responsive button height (desktop optimized)
  static double responsiveButtonHeight(BuildContext context) {
    return 56;
  }

  /// Get responsive border radius (desktop optimized)
  static double responsiveBorderRadius(BuildContext context, double baseRadius) {
    return baseRadius * 1.2;
  }
}
