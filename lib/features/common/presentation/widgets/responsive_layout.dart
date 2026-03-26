import 'package:flutter/material.dart';

/// A responsive container that prevents overflow by providing proper scrolling
/// and safe area handling for form layouts and content.
class ResponsiveFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final bool enableScrolling;

  const ResponsiveFormContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
    this.enableScrolling = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Add padding if provided
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Add centering if enabled
    if (centerContent) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              (padding?.vertical ?? 48),
        ),
        child: IntrinsicHeight(child: content),
      );
    }

    // Add scrolling if enabled
    if (enableScrolling) {
      content = SingleChildScrollView(
        padding: padding,
        child: centerContent ? content : child,
      );
    }

    // Wrap in SafeArea
    return SafeArea(child: content);
  }
}

/// A responsive column that handles overflow gracefully
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool enableFlexibleSpacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.enableFlexibleSpacing = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> responsiveChildren = children;

    // Add flexible spacers if centering and flexible spacing enabled
    if (mainAxisAlignment == MainAxisAlignment.center &&
        enableFlexibleSpacing) {
      responsiveChildren = [
        const Spacer(flex: 1),
        ...children,
        const Spacer(flex: 1),
      ];
    }

    return Column(
      mainAxisAlignment: enableFlexibleSpacing
          ? MainAxisAlignment.start
          : mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: responsiveChildren,
    );
  }
}

/// A responsive row that wraps content when it overflows
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final bool enableWrap;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.enableWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (enableWrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: _wrapAlignment(mainAxisAlignment),
        crossAxisAlignment: _wrapCrossAlignment(crossAxisAlignment),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  WrapAlignment _wrapAlignment(MainAxisAlignment mainAxisAlignment) {
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment _wrapCrossAlignment(
    CrossAxisAlignment crossAxisAlignment,
  ) {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
        return WrapCrossAlignment.start; // Wrap doesn't support stretch
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.start; // Wrap doesn't support baseline
    }
  }
}

/// A responsive container that adapts based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16.0),
    this.tabletPadding = const EdgeInsets.all(24.0),
    this.desktopPadding = const EdgeInsets.all(32.0),
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    EdgeInsetsGeometry padding;
    if (screenWidth < mobileBreakpoint) {
      padding = mobilePadding ?? const EdgeInsets.all(16.0);
    } else if (screenWidth < tabletBreakpoint) {
      padding = tabletPadding ?? const EdgeInsets.all(24.0);
    } else {
      padding = desktopPadding ?? const EdgeInsets.all(32.0);
    }

    return Padding(padding: padding, child: child);
  }
}

/// Extension to check screen size breakpoints
extension ResponsiveExtensions on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}
