import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileScreen = 600;
  static const double tabletScreen = 900;
  static const double desktopScreen = 1200;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileScreen;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileScreen && width < desktopScreen;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopScreen;
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Get responsive card padding
  static EdgeInsets responsiveCardPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    }
    if (isTablet(context)) {
      return 3;
    }
    return 2;
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktopScreen) {
      return baseSize * 1.2;
    }
    if (screenWidth >= tabletScreen) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktopScreen) {
      return baseSize * 1.3;
    }
    if (screenWidth >= tabletScreen) {
      return baseSize * 1.15;
    }
    return baseSize;
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktopScreen) {
      return baseSpacing * 1.5;
    }
    if (screenWidth >= tabletScreen) {
      return baseSpacing * 1.25;
    }
    return baseSpacing;
  }

  /// Get responsive container max width
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    }
    if (isTablet(context)) {
      return 900;
    }
    return double.infinity;
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 56;
    }
    if (isTablet(context)) {
      return 52;
    }
    return 48;
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktopScreen) {
      return baseRadius * 1.2;
    }
    if (screenWidth >= tabletScreen) {
      return baseRadius * 1.1;
    }
    return baseRadius;
  }
}
