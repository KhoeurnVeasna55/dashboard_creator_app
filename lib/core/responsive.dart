import 'package:flutter/material.dart';

enum ResponsiveType { mobile, smallTablet, tablet, desktop, largeDesktop }

extension ResponsiveContext on BuildContext {
  MediaQueryData get media => MediaQuery.of(this);
  double get width => media.size.width;
  double get height => media.size.height;

  ResponsiveType get responsiveFactor {
    if (width < 713) {
      return ResponsiveType.mobile;
    } else if (width < 900) {
      return ResponsiveType.smallTablet;
    } else if (width < 1200) {
      return ResponsiveType.tablet;
    } else {
      return ResponsiveType.desktop;
    }
  }

  bool get isMobile => responsiveFactor == ResponsiveType.mobile;
  bool get isSmallTablet => responsiveFactor == ResponsiveType.smallTablet;
  bool get isTablet => responsiveFactor == ResponsiveType.tablet;
  bool get isDesktop => responsiveFactor == ResponsiveType.desktop;
  bool get isLargeDesktop => responsiveFactor == ResponsiveType.largeDesktop;
}
