import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Convenience extensions on [BuildContext] to reduce boilerplate when
/// accessing theme data, screen dimensions, and common UI actions.
extension ThemeExtensions on BuildContext {
  /// Shorthand for `Theme.of(context)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(context).colorScheme`.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shorthand for `Theme.of(context).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension MediaQueryExtensions on BuildContext {
  /// The current screen width in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The current screen height in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

extension ResponsiveExtensions on BuildContext {
  /// Returns `true` when the screen width is below [AppConstants.phoneMaxWidth].
  bool get isPhone => screenWidth < AppConstants.phoneMaxWidth;

  /// Returns `true` when the screen width is between phone and tablet
  /// breakpoints.
  bool get isTablet =>
      screenWidth >= AppConstants.phoneMaxWidth &&
      screenWidth <= AppConstants.tabletMaxWidth;

  /// Returns `true` when the screen width exceeds [AppConstants.tabletMaxWidth].
  bool get isDesktop => screenWidth > AppConstants.tabletMaxWidth;
}

extension SnackBarExtensions on BuildContext {
  /// Shows a [SnackBar] with the given [message].
  ///
  /// Optionally accepts a [duration] (defaults to 4 seconds) and an [action].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
  }
}
