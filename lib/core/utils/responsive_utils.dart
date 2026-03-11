import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  /// Returns true when the screen width is below the phone breakpoint.
  static bool isPhone(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < AppConstants.phoneMaxWidth;
  }

  /// Returns true when the screen width falls between phone and tablet
  /// breakpoints (inclusive of phone max, exclusive of tablet max).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.phoneMaxWidth &&
        width <= AppConstants.tabletMaxWidth;
  }

  /// Returns true when the screen width exceeds the tablet breakpoint.
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width > AppConstants.tabletMaxWidth;
  }

  /// Returns a recommended column count based on device class.
  ///
  /// Phone: 2, Tablet: 3, Desktop: 4.
  static int columns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Returns horizontal padding appropriate for the current device class.
  ///
  /// Phone: 16, Tablet: 24, Desktop: 32.
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return AppConstants.paddingXL;
    if (isTablet(context)) return AppConstants.paddingLG;
    return AppConstants.paddingMD;
  }
}
