import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Responsive breakpoints
  static const double mobileScreen = 600;
  static const double tabletScreen = 900;
  static const double desktopScreen = 1200;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileScreen;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileScreen && width < desktopScreen;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopScreen;
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
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
  }

  /// Get responsive card padding
  static EdgeInsets responsiveCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 4;
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.05;
    } else {
      return baseSize * 1.1;
    }
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.15;
    } else {
      return baseSpacing * 1.3;
    }
  }

  /// Get responsive container max width
  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 1000;
    } else {
      return 1400;
    }
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48;
    } else if (isTablet(context)) {
      return 50;
    } else {
      return 52;
    }
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(BuildContext context, double baseRadius) {
    if (isMobile(context)) {
      return baseRadius;
    } else if (isTablet(context)) {
      return baseRadius * 1.1;
    } else {
      return baseRadius * 1.2;
    }
  }
}
