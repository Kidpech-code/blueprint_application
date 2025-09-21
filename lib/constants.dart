import 'package:flutter/material.dart';

/// UI constants for consistent design across the application
///
/// This file contains all the UI-related constants including:
/// - Spacing and sizing values
/// - Animation durations
/// - Colors and gradients
/// - Text styles
/// - Icon sizes
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderRadiusCircle = 999.0;

  // Elevation
  static const double elevationLow = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationHigh = 4.0;
  static const double elevationXHigh = 8.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Avatar Sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 96.0;

  // Button Heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonHeightXLarge = 56.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 1000);

  // AppBar Height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 72.0;

  // Bottom Navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavHeightLarge = 72.0;

  // Card Sizes
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;

  // Form Field Heights
  static const double textFieldHeight = 48.0;
  static const double textFieldHeightLarge = 56.0;
  static const double textAreaMinHeight = 120.0;

  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Opacity Values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // List Tile
  static const double listTileHeight = 56.0;
  static const double listTileHeightLarge = 72.0;
  static const double listTileHeightDense = 48.0;

  // Chip
  static const double chipHeight = 32.0;
  static const double chipHeightSmall = 24.0;

  // Progress Indicator
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLarge = 36.0;
  static const double progressIndicatorStrokeWidth = 4.0;

  // Shadow
  static const List<BoxShadow> shadowLow = [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0)];

  static const List<BoxShadow> shadowMedium = [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 8, spreadRadius: 0)];

  static const List<BoxShadow> shadowHigh = [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 16, spreadRadius: 0)];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
  );

  // Text Size
  static const double textSizeXSmall = 10.0;
  static const double textSizeSmall = 12.0;
  static const double textSizeMedium = 14.0;
  static const double textSizeLarge = 16.0;
  static const double textSizeXLarge = 18.0;
  static const double textSizeXXLarge = 20.0;
  static const double textSizeHeadline = 24.0;
  static const double textSizeDisplay = 32.0;

  // Line Height
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Z-Index
  static const int zIndexBase = 0;
  static const int zIndexDropdown = 1000;
  static const int zIndexSticky = 1020;
  static const int zIndexFixed = 1030;
  static const int zIndexModal = 1040;
  static const int zIndexPopover = 1050;
  static const int zIndexTooltip = 1060;
  static const int zIndexToast = 1070;

  // Layout
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 280.0;
  static const double sidebarWidthCollapsed = 64.0;

  // Grid
  static const int gridColumnsXSmall = 1;
  static const int gridColumnsSmall = 2;
  static const int gridColumnsMedium = 3;
  static const int gridColumnsLarge = 4;
  static const int gridColumnsXLarge = 6;

  // Common Curves
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
}

/// Asset constants for consistent asset management
class AssetConstants {
  AssetConstants._();

  // Images
  static const String imagePath = 'assets/images';
  static const String logoPath = '$imagePath/logo.png';
  static const String placeholderPath = '$imagePath/placeholder.png';
  static const String avatarPlaceholderPath = '$imagePath/avatar_placeholder.png';
  static const String emptyStatePath = '$imagePath/empty_state.png';
  static const String errorStatePath = '$imagePath/error_state.png';

  // Icons
  static const String iconPath = 'assets/icons';

  // Lottie Animations
  static const String lottiePath = 'assets/lottie';
  static const String loadingAnimationPath = '$lottiePath/loading.json';
  static const String successAnimationPath = '$lottiePath/success.json';
  static const String errorAnimationPath = '$lottiePath/error.json';

  // Fonts
  static const String fontFamily = 'Roboto';
  static const String fontFamilyMono = 'RobotoMono';
}

/// Color constants for the application theme
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  static const Color secondaryLight = Color(0xFFBA68C8);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Dark Theme Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textHintDark = Color(0xFF666666);
  static const Color textDisabledDark = Color(0xFF4D4D4D);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF333333);
  static const Color borderFocus = Color(0xFF2196F3);
  static const Color borderError = Color(0xFFF44336);

  // Transparent Colors
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}
