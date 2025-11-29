import 'package:flutter/material.dart';

/// A responsive wrapper that constrains content width on larger screens
/// and centers it horizontally.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }

  /// Helper to check if we're on a wide screen (desktop/tablet)
  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// Helper to check if we're on a desktop-sized screen
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    } else if (width > 900) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else if (width > 600) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.all(20);
  }
}
