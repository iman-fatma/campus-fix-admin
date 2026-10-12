import 'package:flutter/material.dart';

/// Responsive helper breakpoints and utility methods
class ResponsiveHelper {
  static const double mobileMaxWidth = 768.0;
  static const double tabletMaxWidth = 1100.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxWidth;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}

/// A clean, declarative widget to render Mobile, Tablet, and Desktop layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.tabletMaxWidth) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveHelper.mobileMaxWidth) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
